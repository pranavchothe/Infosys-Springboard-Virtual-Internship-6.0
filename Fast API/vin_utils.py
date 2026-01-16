import requests

def decode_vin(vin: str) -> dict:
    print("🔍 decode_vin() CALLED WITH:", vin)

    url = f"https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/{vin}?format=json"
    response = requests.get(url, timeout=10)

    data = response.json()

    result = {}
    for item in data.get("Results", []):
        if item.get("Variable") and item.get("Value"):
            result[item["Variable"]] = item["Value"]

    decoded = {
        "vin": vin,
        "make": result.get("Make"),
        "model": result.get("Model"),
        "model_year": result.get("Model Year"),
        "body_class": result.get("Body Class"),
        "fuel_type": result.get("Fuel Type - Primary"),
        "engine_model": result.get("Engine Model"),
        "plant_country": result.get("Plant Country"),
        "manufacturer": result.get("Manufacturer Name"),
    }

    return decoded
