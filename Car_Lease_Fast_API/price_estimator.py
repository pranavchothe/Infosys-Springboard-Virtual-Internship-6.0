def estimate_car_price(
    vehicle_details: dict,
    car_history: dict | None,
    fairness_analysis: dict | None,
):
    """
    Estimate market price based on:
    - Year depreciation
    - Accident history
    - Flood damage
    - Ownership count
    - Insurance claims
    - Lease risk score
    """
   
    #  BASE PRICE (Mock Logic)
    
    year = vehicle_details.get("year")
    base_price = 800000  # default base (INR) if unknown

    if year:
        current_year = 2026
        age = current_year - int(year)
        depreciation = age * 0.07  # 7% per year
        base_price = base_price * (1 - depreciation)

    estimated_price = base_price

    # HISTORY IMPACT
  
    if car_history:
        accidents = car_history.get("accident_count", 0)
        flood = car_history.get("flood_damage", False)
        owners = car_history.get("number_of_owners", 1)
        insurance_claims = car_history.get("insurance_claims", 0)

        # Accident impact
        estimated_price -= accidents * 25000

        # Flood damage
        if flood:
            estimated_price *= 0.7  # heavy drop

        # Multiple owners
        if owners > 2:
            estimated_price *= 0.9

        # Insurance claims
        estimated_price -= insurance_claims * 15000

    
    # FAIRNESS RISK IMPACT
  
    if fairness_analysis:
        score = fairness_analysis.get("fairness_score", 100)

        if score < 60:
            estimated_price *= 0.95  

    # Final safety
    if estimated_price < 100000:
        estimated_price = 100000

    return {
        "estimated_market_value": round(estimated_price, 2),
        "recommended_negotiation_price": round(estimated_price * 0.95, 2),
        "confidence": "Medium",
    }
