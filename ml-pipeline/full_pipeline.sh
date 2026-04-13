#!/bin/bash

# Exit immediately if any command fails
set -e

# Load Conda into the CRON environment
source /home/azureuser/miniconda3/etc/profile.d/conda.sh

# Activate environment
conda activate cs26

# Navigate to the project root
cd /home/azureuser/model/ml-pipeline

echo "========================================="
echo "Starting Daily Data Fetch & Training..."
echo "========================================="
# Fetch all data up through yesterday and retrain the model
python run_pipeline.py full --start-season 2015 --end-season 2024

echo "========================================="
echo "Starting Today's Predictions & API Push..."
echo "========================================="
# Make predictions using the freshly trained model
python scripts/cron_pipeline.py

echo "Daily pipeline completed successfully!"