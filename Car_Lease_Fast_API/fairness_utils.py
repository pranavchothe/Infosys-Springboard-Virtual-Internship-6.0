def calculate_fairness(analysis_json: dict) -> dict:
    score = 100
    red_flags = []

    penalties = analysis_json.get("5.penalties", {}) or analysis_json.get("penalties", {}) or {}
    lease_details = analysis_json.get("2.lease_details", {}) or analysis_json.get("lease_details", {}) or {}
    financials = analysis_json.get("4.financials", {}) or analysis_json.get("financials", {}) or {}
    termination_clause = (analysis_json.get("6.termination_clause") or analysis_json.get("termination_clause") or "").lower()

    # 1. PENALTY SEVERITY
    penalty_count = sum(1 for v in penalties.values() if v)
    if penalty_count >= 3:
        score -= 10
        red_flags.append("Multiple penalties may apply simultaneously, increasing financial risk.")
    elif penalty_count == 2:
        score -= 5
        red_flags.append("Several penalties are defined in the contract.")

    # 1.5 TERMINATION COST SEVERITY
    termination_fee = penalties.get("early_termination_charge")

    try:
        fee_val = float(
            str(termination_fee)
            .replace("INR", "")
            .replace(",", "")
            .strip()
        )

        if fee_val >= 200000:
            score -= 20
            red_flags.append("Extremely high early termination charge.")
        elif fee_val >= 100000:
            score -= 12
            red_flags.append("High early termination charge.")
        elif fee_val <= 25000:
            score += 5  # 👈 reward fair contracts
    except:
        pass



    # 2. CONTRACT CLARITY (DATES)
    if not lease_details.get("start_date"):
        score -= 5
        red_flags.append("Lease start date is missing or unclear.")

    if not lease_details.get("end_date"):
        score -= 5
        red_flags.append("Lease end date is missing or unclear.")

    # 3. PAYMENT TRANSPARENCY
    base = financials.get("base_monthly_payment")
    total = financials.get("total_monthly_payment")

    try:
        if base and total:
            base_val = float(str(base).replace("INR", "").replace(",", "").strip())
            total_val = float(str(total).replace("INR", "").replace(",", "").strip())
            if total_val > base_val * 1.25:
                score -= 10
                red_flags.append("Total monthly payment is significantly higher than base payment (possible hidden charges).")
            elif total_val > base_val * 1.1:
                score -= 5
                red_flags.append("Total monthly payment is higher than base payment.")
    except:
        pass

    # 3.5 LEASE DURATION FAIRNESS
    duration = lease_details.get("lease_duration")

    try:
        duration_val = int(str(duration).split()[0])

        if duration_val >= 60:
            score -= 15
            red_flags.append("Very long lease duration significantly reduces flexibility.")
        elif duration_val >= 48:
            score -= 10
            red_flags.append("Long lease duration reduces flexibility.")
        elif duration_val <= 24:
            score += 5  
    except:
        pass


    # 4. TERMINATION FAIRNESS
    if "sole discretion of lessor" in termination_clause or "lessee may not terminate" in termination_clause:
        score -= 15
        red_flags.append("Termination rights appear one-sided in favor of the lessor.")
    elif "terminate early subject to charges" in termination_clause:
        score -= 5
        red_flags.append("Early termination is allowed only with penalties.")

    # 5. CONSUMER PROTECTION
    if "insurance" not in termination_clause:
        score -= 5
        red_flags.append("No mention of insurance obligations or coverage.")

    if "cooling" not in termination_clause:
        score -= 10
        red_flags.append("No cooling-off period mentioned for contract cancellation.")

    # FINAL SCORE

    score = max(0, min(score, 100))

    if score < 0:
        score = 0

    if score >= 80:
        verdict = "Fair"
    elif score >= 60:
        verdict = "Moderate"
    else:
        verdict = "Unfair"

    return {
        "fairness_score": score,
        "fairness_verdict": verdict,
        "red_flags": red_flags
    }
