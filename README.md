#  System Identification in Simulink | Non-Parametric & Parametric Methods

##  Overview
This project focuses on system identification techniques implemented in Simulink, covering both non-parametric and parametric methods. The goal is to model and identify dynamic systems using different types of input signals and estimation approaches.

--- 

##  Objectives
*  Perform identification in both time and frequency domains
*  Analyze system behavior using step, chirp, and PRBS signals
*  Apply non-parametric (linear regression) and parametric (polynomial models) methods
*  Evaluate different structures like ARX, ARMAX, Box-Jenkins, and N4SID

---

##  Methods Used

### 1. Non-Parametric Identification
*  Identification of second-order systems using **Linear Regression** with step input signals
    *  Identifying a hydraulic process with two tanks in series
*  Estimating response using **Chirp signals** (VCO) to capture resonance points

### 2. Parametric Identification
*  **SPAB / PRBS** (Pseudo-Random Binary Signals)
* **Estimation Structures:**
    * **ARX & ARMAX:** Polynomial models for coupled noise dynamics
    * **OE (Output Error) & Box-Jenkins (BJ):** Flexible structures for separate noise modeling
    * **N4SID:** Subspace-based state-space identification

---

##  Tools and Technologies
* **MATLAB & Simulink** 
* **System Identification Toolbox**
* **Control System Toolbox** 

---

##  How to Run
1. Open **MATLAB**.
2. Navigate to the project folder (e.g., `PROIECT_IS`).
3. Open the desired Simulink model (`.slx`) found in the subfolders like `P1, P2`.
4. Run the simulation.
5. Use the provided `.m` scripts (e.g., `setup_convertor.m`) for data analysis and parameter identification.

---

##  Key Results
* The project demonstrates how different input signals and identification methods influence the accuracy of the estimated model, highlighting the differences between time-domain and frequency-domain approaches.
