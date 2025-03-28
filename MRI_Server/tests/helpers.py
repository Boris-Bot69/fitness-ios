def get_patient_username(testapp):
    resp = testapp.get(f"/api/v1/patients")
    patients = [patient["username"] for patient in resp.json.values()]
    assert patients, "`patient` fixture should have provided at least one patient"
    return patients[0]
