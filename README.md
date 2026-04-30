# Data at Bat ⚾

**Developed by Team Non-Evil Palantir**

Data at Bat is a comprehensive sports analytics and predictive modeling platform designed to forecast Major League Baseball (MLB) game outcomes. By leveraging historical game logs, advanced pitcher metrics (WAR, ERA, WHIP), and rolling team form, the platform calculates highly accurate win probabilities. It then synchronizes these predictions against live sportsbook odds to identify mathematical "edges" and value bets for end-users.

---

## Key Features

* **Algorithmic Predictions:** A robust machine learning pipeline utilizing LightGBM to evaluate pitching matchups, recent team performance, and historical data to predict daily game winners.
* **Value Edge Calculation:** Automatically compares model-derived win probabilities against live moneyline and spread odds to highlight actionable betting value.
* **Automated Data Pipeline:** A fully automated architecture that fetches daily schedules, processes game logs, runs model inference, and pushes payload batches to the cloud.
* **Personalized Dashboards:** Secure user accounts managed via Firebase Authentication, allowing users to save favorite teams, manage subscriptions, and view tailored daily prediction feeds.
* **Cross-Platform Mobile App:** A responsive, natively compiled mobile and web interface built with Flutter.

---

## Architecture & Tech Stack

* **Frontend (Mobile/Web):** Flutter, Riverpod (State Management), GoRouter (Routing).
* **Backend API:** Java, Spring Boot, Hibernate/JPA.
* **Database:** PostgreSQL (Cloud hosting via Neon).
* **Machine Learning:** Python, Pandas, Scikit-Learn, LightGBM, Joblib.
* **Infrastructure & Security:** Microsoft Azure VM (CRON scheduling), Firebase Admin SDK (Authentication), Google Cloud Platform.

---

## Getting Started

Follow these steps to configure and run the full stack locally for development.

### 1. Prerequisites
Ensure you have the following installed on your local machine:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0+)
* [Java JDK 17+](https://adoptium.net/) & Maven
* [Python 3.9+](https://www.python.org/downloads/)

### 2. Clone the Repository
```bash
git clone [https://github.com/your-username/capstone2026.git](https://github.com/your-username/capstone2026.git)
cd capstone2026
```

### 3. Environment & Security Configuration
You must configure your local environment variables before running the application.

Frontend (app/.env):
Create an .env file in the app directory containing your Firebase Web, iOS, and Android API keys.


```bash
WEB_API_KEY=your_web_api_key
WEB_APP_ID=your_web_app_id
... other firebase keys
```

#### Backend (data-at-bat-api/src/main/resources/):

1. Download your Firebase Admin SDK Service Account JSON file.

2. Rename it to firebase-adminsdk.json and place it in the resources directory.

3. Ensure your application.properties is configured for your local or Neon PostgreSQL database.

#### Machine Learning (ml-pipeline/.env):

Create an .env file in the ML directory containing your database URL, external API keys, and backend endpoint.

```bash
API_URL=http://dataatbat.hopto.org:8080/games?batch=true / (localhost:8080 if ran locally)
THE_ODDS_API_KEY=your_odds_api_key
```

### 4. Running the Backend API

Navigate to the Spring Boot directory and start the server:

```bash
cd data-at-bat-api
mvn spring-boot:run
```

### 5. Running the ML Pipeline

Navigate to the Python directory, install the required packages, and run the daily pipeline:

```bash
cd ml-pipeline
pip install -r requirements.txt
python run_pipeline.py full --start-season=2015 --end-season=2024
```

This will fetch today's MLB schedule, generate predictions, and POST the batch data to your running Spring Boot API.

### 6. Running the Frontend Application


Navigate to the Flutter directory, fetch dependencies, and launch the application. The --dart-define-from-file flag is strictly required to inject the Firebase API keys into the runtime environment.

```bash
cd app
flutter pub get

# Run on Chrome
flutter run -d chrome --dart-define-from-file=.env

# Run on iOS Simulator / Android Emulator
flutter run --dart-define-from-file=.env
```

### 7. Production Deployment

API & Database: The production backend runs on a managed cloud environment, connected to a Neon Serverless PostgreSQL instance.

Automated Predictions: The full_pipeline.py script is deployed on an Azure Virtual Machine and triggered daily at 03:00 AM via a CRON scheduler to fetch new game data and update the database automatically.