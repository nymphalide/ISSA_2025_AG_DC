import asyncio
import websockets
import json
import sys
import aioconsole
from car_state import CarState

SERVER_WS_URL = "ws://localhost:8080/car-ws"


async def listen_to_server(websocket, car):
    """Observer for incoming server commands."""
    try:
        async for message in websocket:
            data = json.loads(message)
            action = data.get("action")

            if action == "UNLOCK_CAR":
                car.unlock()

            elif action == "LOCK_CAR":
                car.lock()

            elif action == "QUERY_STATE":
                report = {
                    "action": "STATE_REPORT",
                    "payload": car.get_status_report()
                }
                await websocket.send(json.dumps(report))
                print(f"[{car.vin}] Backend queried state. Report sent.")

    except websockets.exceptions.ConnectionClosed:
        print(f"[{car.vin}] Connection to server closed by the backend.")
        sys.exit(0)


async def listen_to_terminal(car):
    """Observer for physical simulation via terminal input."""
    print("Available physical commands: 'open', 'close', 'lights', 'status', 'quit'")
    while True:
        command = await aioconsole.ainput()
        command = command.strip().lower()

        match command:
            case "open":
                car.open_door()
            case "close":
                car.close_door()
            case "lights":
                car.toggle_lights()
            case "status":
                print(f"[{car.vin}] Current State: {car.get_status_report()}")
            case "quit":
                print("Closing...")
                return
            case _:
                print("Unknown command.")


async def main():
    if len(sys.argv) < 2:
        print("Usage: python main.py <VIN>")
        return

    vin = sys.argv[1]
    car = CarState(vin)

    print(f"Starting telematics module for {car.vin}...")

    try:
        async with websockets.connect(SERVER_WS_URL) as websocket:

            # 1. Send the Handshake immediately
            handshake = {
                "action": "REGISTER_CAR",
                "vin": car.vin
            }
            await websocket.send(json.dumps(handshake))

            # 2. Wait for the Server's ACK/NACK verdict
            response_str = await websocket.recv()
            response = json.loads(response_str)

            if response.get("status") == "SUCCESS":
                print(f"[{car.vin}] Connected and verified by backend!")

                # STATE SYNCHRONIZATION PATTERN implementation
                is_rented = response.get("is_rented")

                if is_rented is True:
                    car.unlock()
                    print(f"[{car.vin}] Sync: Car is actively rented. Doors UNLOCKED.")
                elif is_rented is False:
                    car.lock()
                    print(f"[{car.vin}] Sync: Car is available. Doors LOCKED.")
                else:
                    print(f"[{car.vin}] Warning: No sync state received from server.")

            else:
                error_msg = response.get("message", "Unknown error")
                print(f"[{car.vin}] Registration failed: {error_msg}")
                return  # Exits the script immediately, closing the pipe

            # 3. If verified, run both observers concurrently
            server_task = asyncio.create_task(listen_to_server(websocket, car))
            terminal_task = asyncio.create_task(listen_to_terminal(car))

            done, pending = await asyncio.wait(
                [server_task, terminal_task],
                return_when=asyncio.FIRST_COMPLETED
            )

            # Clean up the other task that is still running
            for task in pending:
                task.cancel()

    except ConnectionRefusedError:
        print(f"[{car.vin}] Failed to connect to server. Is Spring Boot running?")


if __name__ == "__main__":
    asyncio.run(main())