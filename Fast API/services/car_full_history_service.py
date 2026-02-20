import requests
import random


class CarFullHistoryService:

    def fetch_vehicle_specs(self, vin: str):
        """
        Calls US Govt NHTSA VIN Decoder API
        """
        url = f"https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvaluesextended/{vin}?format=json"

        response = requests.get(url, timeout=10)

        if response.status_code != 200:
            raise Exception("Failed to fetch data from NHTSA")

        data = response.json()

        if not data.get("Results"):
            raise Exception("Invalid VIN or no data from NHTSA")

        result = data["Results"][0]

        return {
            "make": result.get("Make", "Unknown"),
            "model": result.get("Model", "Unknown"),
            "year": result.get("ModelYear", "Unknown")
        }

    def generate_mock_history(self):
        """
        Mock history engine (API-ready for real provider later)
        """

        accidental = random.choice([True, False, False])  # more likely False
        flood_damage = random.choice([False, False, False, True])
        owners = random.randint(1, 3)
        insurance_claims = random.randint(0, 2)
        stolen = False if not accidental else random.choice([False, False, True])

        if stolen:
            status = "Stolen Record Found"
        elif accidental or flood_damage:
            status = "Damage History Found"
        else:
            status = "Clean Record"

        return {
            "accidental": accidental,
            "flood_damage": flood_damage,
            "owners": owners,
            "insurance_claims": insurance_claims,
            "stolen": stolen,
            "status": status
        }

    def fetch_full_history(self, vin: str):
        specs = self.fetch_vehicle_specs(vin)
        history = self.generate_mock_history()

        return {
            "vin": vin,
            "make": specs["make"],
            "model": specs["model"],
            "year": specs["year"],

            "accidental": history["accidental"],
            "flood_damage": history["flood_damage"],
            "owners": history["owners"],
            "insurance_claims": history["insurance_claims"],
            "stolen": history["stolen"],
            "status": history["status"],
            "source": "NHTSA + Mock History (API-Ready)"
        }
