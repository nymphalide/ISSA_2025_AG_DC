class CarState:
    def __init__(self, vin):
        self.vin = vin
        self.is_locked = True
        self.doors_closed = True
        self.lights_off = True

    def unlock(self):
        self.is_locked = False
        print(f"[{self.vin}] Backend command: Car is now UNLOCKED.")

    def lock(self):
        # The backend should verify doors/lights before sending this command
        self.is_locked = True
        print(f"[{self.vin}] Backend command: Car is now LOCKED.")

    def open_door(self):
        if self.is_locked:
            print(f"[{self.vin}] Physical Error: Cannot open door. Car is locked.")
        else:
            self.doors_closed = False
            print(f"[{self.vin}] Physical Action: Door opened.")

    def close_door(self):
        self.doors_closed = True
        print(f"[{self.vin}] Physical Action: Door closed.")

    def toggle_lights(self):
        # We allow lights to be toggled anytime for simplicity
        self.lights_off = not self.lights_off
        state = "OFF" if self.lights_off else "ON"
        print(f"[{self.vin}] Physical Action: Exterior lights are now {state}.")

    def get_status_report(self):
        return {
            "vin": self.vin,
            "is_locked": self.is_locked,
            "doors_closed": self.doors_closed,
            "lights_off": self.lights_off
        }