# PreheatCalc

An iOS app that calculates the optimal time to put food in the oven — before it finishes preheating — so your food is done sooner without overcooking.

## The Idea

Most recipes assume you wait until the oven is fully preheated before starting the clock. But ovens heat up gradually, and food can start cooking the moment you put it in. PreheatCalc models your oven's heat curve and figures out the exact moment to start cooking so the food accumulates the right amount of heat energy by the time you want it done.

## How It Works

The oven temperature over time is modeled with Newton's Law of Heating:

```
T(t) = T_room + (T_target - T_room) × (1 - e^(−kt))
```

where `k` is a heating constant derived from your oven's preheat time. The instantaneous cooking rate at any moment is the fraction of target temperature the oven has reached above the food's starting temperature. PreheatCalc integrates this rate over time (trapezoidal method) and uses bisection search to find the total elapsed time at which accumulated cooking equals the package's cook time.

This means a 12-minute dish cooked at 425°F in an oven that takes 15 minutes to preheat might only need 13–14 total minutes if you put the food in right away — saving you 10+ minutes of real time.

## Features

- **Oven profiles** — Save your oven's preheat time and calibration temperature so the model is specific to your appliance
- **Food starting temperature** — Account for room temp, refrigerated, or frozen food, or enter a custom temperature
- **Cooking chart** — Visual chart showing oven temperature and cumulative cooking progress over time
- **Time saved badge** — Shows how many minutes you save vs. the conventional wait-then-cook method
- **°F / °C toggle** — All inputs and outputs switch units

## Tech Stack

- Swift / SwiftUI
- SwiftData for persistent oven profiles
- Swift Charts for the cooking progress chart
- Targets iOS 17+

## Project Structure

```
PreheatCalc/
├── Models/
│   ├── OvenProfile.swift        # SwiftData model for saved ovens
│   ├── CookingCalculator.swift  # Newton's Law integration + bisection solver
│   ├── CookingResult.swift      # Result struct with chart data
│   └── TemperatureUnit.swift    # °F / °C enum
├── Views/
│   ├── Calculator/
│   │   ├── CalculatorView.swift # Main input form
│   │   ├── ResultsView.swift    # Full results sheet
│   │   └── CookingChartView.swift
│   └── OvenProfiles/
│       ├── OvenProfileListView.swift
│       └── OvenProfileEditView.swift
└── Utilities/
    └── TemperatureConverter.swift
```
