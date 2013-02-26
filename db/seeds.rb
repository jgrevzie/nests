Procedure.create(:name => "Coronary Angiography", :abbrev => "C/A", :options => "Set Up ONLY, Inject, Non-Inject")
Procedure.create(:name => "Percutaneious Coronary Intervention", :abbrev => "PCI", :options => "Set Up ONLY, Inject, Non-Inject")
Procedure.create(:name => "Percutaneous transluminal coronay angioplasty", :abbrev => "PTCA", :options => "Set Up ONLY, Inject, Non-Inject")
Procedure.create(:name => "Plain old balloon angioplasty", :abbrev => "POBA", :options => "Set Up ONLY, Inject, Non-Inject")
Procedure.create(:name => "Permanent Pacemaker", :abbrev => "PPM", :options => "Set Up ONLY, Assist with Procedure")
Procedure.create(:name => "Rotablator", :abbrev => "ROTA", :options => "")
Procedure.create(:name => "Fractional Flow Reserve", :abbrev => "FFR", :options => "")
Procedure.create(:name => "Intravascular Ultrasound", :abbrev => "IVUS", :options => "")
Procedure.create(:name => "Optimal Computer Tomography", :abbrev => "OCT", :options => "")
Procedure.create(:name => "Fliterwire", :abbrev => "FILTER", :options => "")
Procedure.create(:name => "Thrombectomy Device", :abbrev => "", :options => "")
Procedure.create(:name => "Intra-Aotic Balloon Pump", :abbrev => "IABP", :options => "")
Procedure.create(:name => "Pericardiocentesis", :abbrev => "", :options => "")
Procedure.create(:name => "Bi-Ventricular Pacemaker", :abbrev => "BI V", :options => "")
Procedure.create(:name => "Automatic Internal Cardiac Defibrillator", :abbrev => "AICD, ICD", :options => "")
Procedure.create(:name => "Femoral Sheath Removal", :abbrev => "", :options => "")
Procedure.create(:name => "Radial Sheath Removal", :abbrev => "", :options => "")
Procedure.create(:name => "Vascular Closure device", :abbrev => "VCD", :options => "")
Procedure.create(:name => "Renal Denervation", :abbrev => "", :options => "")
Procedure.create(:name => "Percutaneous Core Valve", :abbrev => "", :options => "")
Procedure.create(:name => "Trans-Aortic Valve Implantation", :abbrev => "TAVI", :options => "")
Procedure.create(:name => "Mitral Clip", :abbrev => "", :options => "")
Procedure.create(:name => "Septal Puncture", :abbrev => "", :options => "")
Procedure.create(:name => "Structural Heart - Patent Foramen Ovale", :abbrev => "PFO", :options => "")
Procedure.create(:name => "Structural Heart - Patent Ductus Arteriosus", :abbrev => "PDA", :options => "")
Procedure.create(:name => "Structural Heart - Atrial Septal Defect", :abbrev => "ASD", :options => "")
Procedure.create(:name => "Structural Heart - Left Atrial Appendage", :abbrev => "LAA", :options => "")
Procedure.create(:name => "Valvuloplasty", :abbrev => "", :options => "Mitral, Aortic, Pulmonary, Tricuspid")
Procedure.create(:name => "Exercise Stress Test", :abbrev => "", :options => "")
Procedure.create(:name => "Dobutamine Stress Echo", :abbrev => "DSE", :options => "")
Procedure.create(:name => "Transoesophageal Echogardiography", :abbrev => "TOE", :options => "Bubble study?")
Procedure.create(:name => "Elective DCR", :abbrev => "", :options => "")
Procedure.create(:name => "Temporary  Pacing Wire ", :abbrev => "Temp wire", :options => "")
Procedure.create(:name => "Emergency Intubation", :abbrev => "", :options => "")
Procedure.create(:name => "Covered Stent", :abbrev => "", :options => "")
Procedure.create(:name => "Advanced Life Support", :abbrev => "ALS", :options => "")
Procedure.create(:name => "Basic Life  Support", :abbrev => "BLS", :options => "")
Procedure.create(:name => "Intra venous Cannulation", :abbrev => "IVC", :options => "")
Procedure.create(:name => "Intra venous Therapy", :abbrev => "IVT", :options => "")
Procedure.create(:name => "Ventricular assist device", :abbrev => "VAD", :options => "")
Procedure.create(:name => "Interventional Nurses Council", :abbrev => "INC", :options => "")
Procedure.create(:name => "Femostop device", :abbrev => "Fem stop", :options => "")
Nurse.create(first_name: "Sheila", last_name: "Thompson", username: "sheila", password: 'password', validator: "true", email: "jgrevzie@gmail.com")
Nurse.create(first_name: "Heather", last_name: "Macfarlane", username: "heather", password: 'password', validator: "true", email: "jgrevzie@gmail.com")
Nurse.create(first_name: "Stephanie", last_name: "Renfrey", username: "srenfrey", password: 'password', validator: "", email: "stephanie.renfrey@svpm.org.au")
Nurse.create(first_name: "Marissa", last_name: "Corcoran", username: "mcorcoran", password: 'password', validator: "", email: "marissa.corcoran@svpm.org.au")
Nurse.create(first_name: "Claire", last_name: "Dillon", username: "cdillon", password: 'password', validator: "", email: "claire.dillon@svpm.org.au")
Nurse.create(first_name: "Jamie", last_name: "Freemantle", username: "jfreemantle", password: 'password', validator: "", email: "jamie.freemantle@svpm.org.au")
Nurse.create(first_name: "Dennis", last_name: "Baloco", username: "dbaloco", password: 'password', validator: "", email: "dennis.baloco@svpm.org.au")
Nurse.create(first_name: "Meagan", last_name: "Docherty", username: "mdocherty", password: 'password', validator: "", email: "meagan.docherty@svpm.org.au")
Nurse.create(first_name: "Wendy", last_name: "Luscombe", username: "wluscombe", password: 'password', validator: "", email: "wendy.luscombe@svpm.org.au")
Nurse.create(first_name: "Alison", last_name: "Murphy", username: "amurphy", password: 'password', validator: "", email: "alison.murphy@svpm.org.au")
Nurse.create(first_name: "Bridie", last_name: "Anderson", username: "banderson", password: 'password', validator: "", email: "bridie.anderson@svpm.org.au")
Nurse.create(first_name: "Max", last_name: "East", username: "meast", password: 'password', validator: "", email: "max.east@svpm.org.au")
Nurse.create(first_name: "Rachel", last_name: "Jack", username: "rjack", password: 'password', validator: "", email: "rachel.jack@svpm.org.au")
Nurse.create(first_name: "Bradley", last_name: "McClay", username: "bmcclay", password: 'password', validator: "", email: "bradley.mcclay@svpm.org.au")
Nurse.create(first_name: "Kim", last_name: "Stasinowsky", username: "kstasinowsky", password: 'password', validator: "", email: "kim.stasinowsky@svpm.org.au")
Nurse.create(first_name: "Alex", last_name: "Amery", username: "aamery", password: 'password', validator: "", email: "alex.amery@svpm.org.au")
Nurse.create(first_name: "Brihony   ", last_name: "Gills", username: "bgills", password: 'password', validator: "", email: "brihony.gills@svpm.org.au")
Nurse.create(first_name: "Robyn", last_name: "Langsford", username: "rlangsford", password: 'password', validator: "", email: "robyn.langsford@svpm.org.au")
Nurse.create(first_name: "Gabrielle ", last_name: "Muir", username: "gmuir", password: 'password', validator: "", email: "gabrielle.muir@svpm.org.au")
Nurse.create(first_name: "Lucy", last_name: "Harris", username: "lharris", password: 'password', validator: "", email: "lucy.harris@svpm.org.au")
Nurse.create(first_name: "Martha", last_name: "Wilson", username: "mwilson", password: 'password', validator: "", email: "martha.wilson@svpm.org.au")
