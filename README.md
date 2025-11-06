# COMPUñeros diabetes predicting IA
The structure of the repository is the following:
- Example_analysis
  - Proporcion_Diagnostico.jpeg
  - Proporcion_Edad.jpeg
  - Proporcion_FP_FN.jpeg
  - R_REPRESENTACION_DIABETES_DIAGNOSTICO.R
- README.md
- ia-diabetes-2.ipynb

  
A web version is also available in Releases inside this respository

## Purpose of the project
This project was created when participating in BeTECH Hackaton contest. We aime to create and train an AI which helps us predict whether a patient has diabetes based on a medical note provided externally.
The results will be given in binary code: 0 meaning that the patient has not have diabetes, and 1 meaning that they do have diabetes.

## ia-diabetes-2.ipynb
The main script named ia-diabetes-2.ipynb contains the code used to create and train the AI.
The first three cells are used to update kaggle features as we were coding in Kaggle but are not needed when using other platforms.

This script contains the core of the creation and training of the AI.
Data processing
We were given an API URL where the data was stored. This code access that API and downloads every record into a .csv file. 
Two .csv files are created: diabetes_train_data.csv and diabetes_test_data.csv.  The former contains the data used to train the model and the later is used to test that trained model.

Routes must be changed in order to save these .csv files in the preferred user’s route.

An important aspect is that the information contained in the column named “medical_note” is treated as a string that will be processed.

### Main pipeline
### Libraries used:
> pandas

> numpy

> from sklearn.model_selection: train_test_split

> from klearn.metrics: f1_score, classification_report

> from sentence_transformers: SentenceTransformer

> from xgboost: XGBClassifier

### Split data
We used train data in order to train the model. But first we will split them in two: 90% to train it and 10% to test the model. This decision was made because test data does not have 0 or 1 that helps us check how well the model works. Later on, we will use 100% of this data to train it and test_data to actual testing.

### Libraries and models used:
- Embedding model: intfloat/multilingual-e5-large 
- Machine learning library: XGBoost (eXtreme Gradient Boosting)

```intfloat/multilingual-e5-large```
is used to encode words into embeddings so that the AI can “understand” what the medical note says. The main reason to use it is that it can process different languages.

```XGBoost ``` library was chosen for its precision, velocity and capability to process big amounts of data.


### Training and test process
By just using XGBoost, intfloat/multilingual-e5-large and a 90% of the training_data we obtained an F1 score of 0.72 for predicting diabetes.
In the next chunks of code we will try to improve that score:
 
### Hypertuning
It allows us to try different ranges of parameters for XGBoost in order to maximize F1

### FEATURE ENGINEERING
It helps us improve intfloat/multilingual-e5-large’s embedding process by telling him abbreviations and different languages for key words used in medical notes for diabetes. We also tell him to understand medical values in diabetes such as blood glucose concentration or HBA1c parameter that are important as well.

Feature engineering combined with the embeddings and hypertuning was used to train the model.

Finally, we used the whole training dataset to train the improved model. We obtained a .csv file that contains predictions made by the model using test_data.

## Example_analysis
This folder contains an R script that will analyze the AI predictions.
.jped images in these folders are just examples of this analysis.

### R_REPRESENTACION_DIABETES_DIAGNOSTICO.R
.ipynb file generates a .csv file that contains the real diagnosis and the results of the AI predictions. These data will be compared to calculate the amount of False Negatives, False Positives, True Negatives and True Positives that helps us understand our model’sdata_ processing. For doing that we use a confusion matrix and represent the results in barplot and piechart format.
