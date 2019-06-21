#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 21 14:02:14 2019

@author: batoor
"""
# Working Libraries #
import pandas as pd
import numpy as np
from fancyimpute import KNN
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import GradientBoostingClassifier
from boruta import BorutaPy
from sklearn.model_selection import cross_val_score

###############################################################################

GOTv2 = pd.read_csv('GOTv2.csv')                # Loading mined DF.


# Target Variables
og_target = GOTv2.loc[:, 'isAlive']             # Define them early on
og_data = GOTv2.drop(['isAlive'], axis=1)       # just in case.

#################### MISSING VALUES ###########################################
print(GOTv2.isnull().sum())                     # Amount of missing values in in given variable.


#### Drop unnecessary variables ####
GOTv3 = GOTv2.drop(columns=['Unnamed: 0',       # IDK why this exists.
                            'dateOfBirth',      # pretty much useless.
                            'mother',
                            'father',           # Only Targaryen are collected
                            'heir',             # and I'm not in the business of finding
                            'isAliveMother',    # all the other on Google one by one
                            'isAliveFather',
                            'isAliveHeir',
                            'house',            # 'birth_house' should be more accurate.
                            'spouse', ])         # I don't care about the name of your spouse, TMI.

print(GOTv3.isnull().sum())                     # Amount of missing values in given variable.


#### Imputing NA ####

GOTv3['hasHeadache'] = GOTv3[                   # People who are not eternaly lonely
    'isAliveSpouse'].fillna(0)

GOTv3.loc[GOTv3['birth_house'] == "Unknown",    # People who are not part of any house
          'MemberOfHouse'] = 0

GOTv3['MemberOfHouse'] = GOTv3[                 # People who are part of any house
    'MemberOfHouse'].fillna(1)

GOTv3['everHeldTitle'] = GOTv3[                 # Ever held title?
    'title'].fillna(0)

GOTv3.loc[GOTv3['everHeldTitle'] != 0,          # Lucky people
          'everHeldTitle'] = 1

GOTv3.loc[GOTv3['birth_house'] == "Unknown",    # Thinking ahead for dummies
          'birth_house'] = np.nan


#### Drop unnecessary variables ####
GOTv4 = GOTv3.drop(columns=['housematch',       # Not needed any longer.
                            'isAliveSpouse', ])  # No longer needed.

print(GOTv4.isnull().sum())                     # Everything looking a-ok


#### Change the data type ####

GOTv4.dtypes                                    # I dont like integers, they cause problems


GOTv5 = GOTv4.apply(pd.to_numeric,              # Turn them bad bois into float
                    errors='ignore',
                    downcast='float')
GOTv5.dtypes                                    # Nice

# GOTv5.to_csv('GOTv5.csv')                     # Lest save this hotshot while we are at it

######################### DUMMIFY #############################################

#### Categorical Variables should be Converted ####

title_dummies = pd.get_dummies(                 # Title
    list(GOTv3['title']),
    drop_first=False)

culture_dummies = pd.get_dummies(               # Culture
    list(GOTv3['culture']),
    drop_first=False)

birth_house_dummies = pd.get_dummies(           # Birth House
    list(GOTv3['birth_house']),
    drop_first=False)


GOTv6 = pd.concat(                              # Concatinate the dummies and OG's like a boss
    [GOTv5.loc[:, :],
     title_dummies,
     culture_dummies,
     birth_house_dummies],
    axis=1)

GOTv6 = GOTv6.drop(['title',                    # Drop the OG variables becuase
                    'culture',                  # dummy bois are in town
                    'birth_house'], axis=1)


#################### MISSING VALUES - AGE EDITION #############################

#### Some people are REALLy OLD ####
GOTv6.loc[GOTv6.name == "Rhaego", 'age'] = 0    # Change Rhaego's age accordinly
GOTv6.loc[GOTv6.name == "Doreah", 'age'] = 25   # Change Doreah's age accordingly


GOTv6['isAlive'].corr(GOTv6['age'])             # -.2 Correlation should be enough to work with

# GOTv6.to_csv('GOTv6.csv')

AGE = GOTv6[['age']]                            # Creating a new clolumn so we can check accuracy


age_numeric = GOTv6.drop([                      # Creating maxtrix with only numbers
    'name'], axis=1).as_matrix()

age_knn_10 = pd.DataFrame(                      # KNN with 10 neighbors to predict age
    KNN(10).fit_transform(age_numeric))

age_knn_3 = pd.DataFrame(                       # KNN with 3 neighbors to predict age
    KNN(3).fit_transform(age_numeric))

AGE_KNN_10 = age_knn_10[[9]]

AGE_KNN_3 = age_knn_3[[9]]

AGEv1 = pd.concat(                              # Check if ages make sense.
    [AGE.loc[:, :],                          # Hah, how am I supposed to know if it makes
     AGE_KNN_10,                            # sense or not... Unless I create another ML
     AGE_KNN_3],                            # algorigthm to predict ages that we already know.
    axis=1)                              # Well go with 3

GOTv7 = GOTv6.copy()

GOTv7['age'] = AGE_KNN_3                        # Jesus take the wheel becuase we just lost OG ages

# GOTv7.to_csv('GOTv7.csv')                     # Save the file just in case


GOTv7['isAlive'].corr(                          # Messed up the correlation even further
    GOTv7['age'])                           # due to missing considarable chunk

# DROPPING AGE BECAUSE PYTHON CANT DO PMM AND MICE HAS ISSUES.
# CHASE, IF YOURE READING THIS, STOP THIS LANGUAGE DISCRIMINATION AND
# EMBRACE R MASTERRACE


GOTv8 = GOTv7.drop([                            # See above comment ^
    'name'], axis=1)

GOTv8 = GOTv8.apply(pd.to_numeric,              # Turn them bad bois into float
                    errors='ignore',
                    downcast='float')

print(bool(1))                                  # Idk why I did this, most likely it caused
print(bool(0))                                  # problems when I didn't

###############################################################################
#############                 MODELS                    #######################
###############################################################################
############################ Logistic Regression #############################

model = LogisticRegression()                    # Creating the model for Logistic Regression

model.fit(GOTv8.drop('isAlive',                 # Unfortunaltely Pyhon doesnt do 'x ~ .,'
                     axis=1), GOTv8['isAlive'])  # like R MASTERRACE does so easily

predicted_classes = model.predict(              # Predict with every variable except 'isAlive'
    GOTv8.drop('isAlive',                   # duh...
               axis=1))

accuracy = accuracy_score(                      # Accuracy for Logistic Regression
    GOTv8['isAlive'],
    predicted_classes)


print(accuracy)                                 # "Sounds good. Doesn't work."

############################# Train - Test Split ##############################

GOT_data = GOTv8.drop(                          # Gather all the data without target
    ['isAlive'],
    axis=1)

GOT_target = GOTv8.loc[:, 'isAlive']             # Set the target as 'isAlive'


X_train, X_test, y_train, y_test = train_test_split(
    GOT_data,                               # Split the daata into train - test
    GOT_target.values.ravel(),
    random_state=508,
    test_size=0.1,
    stratify=GOT_target)


##############################   Random Forest  ###############################

# Full forest GINI
full_forest_gini = RandomForestClassifier(
    n_estimators=500,
    criterion='gini',
    max_depth=None,
    min_samples_leaf=15,
    bootstrap=True,
    warm_start=False,
    random_state=508)


# Full forest Entropy
full_forest_entropy = RandomForestClassifier(
    n_estimators=500,
    criterion='entropy',
    max_depth=None,
    min_samples_leaf=15,
    bootstrap=True,
    warm_start=False,
    random_state=508)


# Fitting the models
full_gini_fit = full_forest_gini.fit(
    X_train, y_train)


full_entropy_fit = full_forest_entropy.fit(
    X_train, y_train)


# Are our predictions the same for each model?

full_gini_fit.predict(X_test).sum() == full_entropy_fit.predict(X_test).sum()


# Scoring the gini model
print('Training Score',
      full_gini_fit.score(X_train,
                          y_train))

print('Testing Score:',
      full_gini_fit.score(X_test,
                          y_test))


# Scoring the entropy model
print('Training Score',
      full_entropy_fit.score(X_train,
                             y_train))

print('Testing Score:',
      full_entropy_fit.score(X_test,
                             y_test))


# Saving score objects
gini_full_train = full_gini_fit.score(
    X_train,
    y_train)

gini_full_test = full_gini_fit.score(
    X_test,
    y_test)

entropy_full_train = full_entropy_fit.score(
    X_train,
    y_train)

entropy_full_test = full_entropy_fit.score(
    X_test,
    y_test)


############# Parameter tuning with GridSearchCV for Random Forest  ###########

# Creating a hyperparameter grid
estimator_space = pd.np.arange(100, 1350, 250)
leaf_space = pd.np.arange(1, 150, 15)
criterion_space = ['gini', 'entropy']
bootstrap_space = [True, False]
warm_start_space = [True, False]


param_grid = {'n_estimators': estimator_space,
              'min_samples_leaf': leaf_space,
              'criterion': criterion_space,
              'bootstrap': bootstrap_space,
              'warm_start': warm_start_space}


full_forest_grid = RandomForestClassifier(      # Creating the model
    max_depth=None,
    random_state=508)


full_forest_cv = GridSearchCV(                  # Creating GridSearchCV object
    full_forest_grid,
    param_grid,
    cv=3)


full_forest_cv.fit(                             # Fit into training data
    X_train,
    y_train)


print("Best Parameters:",                       # Best Parameters
      full_forest_cv.best_params_)

print("Tuned Logistic Regression Accuracy:",    # Tuned Accuracy
      full_forest_cv.best_score_.round(4))


###################  Random Forest Model w/ Best Parameters ##################

rf_optimal = RandomForestClassifier(            # Create the model
    bootstrap=True,
    criterion='entropy',
    min_samples_leaf=1,
    n_estimators=100,
    warm_start=True)


rf_optimal.fit(X_train, y_train)                # Fit the model


rf_optimal_pred = rf_optimal.predict(X_test)    # Lets predict

RF_CM = pd.crosstab(                            # Confusion Matrix
    GOT_target,
    rf_optimal_pred)

print('Training Score',                         # Score on training data
      rf_optimal.score(
          X_train,
          y_train).round(4))


print('Testing Score:',                         # We see test score is >.8
      rf_optimal.score(                         # Thats cool
          X_test,
          y_test).round(4))


rf_optimal_train = rf_optimal.score(            # Lets save them scores
    X_train,
    y_train)

rf_optimal_test = rf_optimal.score(
    X_test,
    y_test)

#################################### GBM #####################################

gbm = GradientBoostingClassifier(               # Initial GBM Model
    loss='deviance',
    learning_rate=1.5,
    n_estimators=100,
    max_depth=3,
    criterion='friedman_mse',
    warm_start=False,
    random_state=508,)

gbm_fit = gbm.fit(                              # Fit the model
    X_train,
    y_train)


gbm_predict = gbm_fit.predict(X_test)           # Lets predict some test data


# Training and Testing Scores
print('Training Score:',
      gbm_fit.score(
          X_train,
          y_train).round(4))

print('Testing Score:',
      gbm_fit.score(
          X_test,
          y_test).round(4))


gbm_train = gbm_fit.score(                      # Save the scores
    X_train,                                # for future reference
    y_train)

gmb_test = gbm_fit.score(
    X_test,
    y_test)

############# Parameter tuning with GridSearchCV for GBM  #####################

# Creating a hyperparameter grid
learn_space = pd.np.arange(0.01, 2.01, 0.05)
estimator_space_GBM = pd.np.arange(50, 1000, 50)
depth_space = pd.np.arange(1, 10)
leaf_space_GBM = pd.np.arange(1, 150, 15)
criterion_space_GBM = ['friedman_mse', 'mse', 'mae']


param_grid_GBM = {'learning_rate': learn_space,
                  'n_estimators': estimator_space_GBM,
                  'max_depth': depth_space,
                  'min_samples_leaf': leaf_space_GBM,
                  'criterion': criterion_space_GBM}


gbm_grid = GradientBoostingClassifier(          # Build the model
    random_state=508)


gbm_grid_cv = GridSearchCV(                     # Creating GridSearchCV object
    gbm_grid,
    param_grid_GBM,
    cv=3)


gbm_grid_cv.fit(X_train, y_train)               # Fit into training data


# Optimal parameters and best score
print("Tuned GBM Parameter:",
      gbm_grid_cv.best_params_)
print("Tuned GBM Accuracy:",
      gbm_grid_cv.best_score_.round(4))


##########################  GBM w/ Best Parameters ###########################

gbm_optimal = GradientBoostingClassifier(
    criterion='friedman_mse',
    learning_rate=0.1,
    max_depth=5,
    n_estimators=100,
    random_state=508)


gbm_optimal.fit(X_train, y_train)


gbm_optimal_score = gbm_optimal.score(X_test, y_test)


gbm_optimal_pred = gbm_optimal.predict(X_test)

GBM_CM = pd.crosstab(                           # Confusion Matrix
    GOT_target,
    rf_optimal_pred)


# Training and Testing Scores
print('Training Score', gbm_optimal.score(X_train, y_train).round(4))
print('Testing Score:', gbm_optimal.score(X_test, y_test).round(4))


gbm_optimal_train = gbm_optimal.score(X_train, y_train)
gmb_optimal_test = gbm_optimal.score(X_test, y_test)


########################
# Saving Results
########################

# Saving best model scores
model_scores_df = pd.DataFrame({'RF_Score': [full_forest_cv.best_score_],
                                'GBM_Score': [gbm_grid_cv.best_score_]})


model_scores_df.to_excel("Ensemble_Model_Results.xlsx")


# Saving model predictions

model_predictions_df = pd.DataFrame({'Actual': y_test,
                                     'RF_Predicted': rf_optimal_pred,
                                     'GBM_Predicted': gbm_optimal_pred})


model_predictions_df.to_excel("Ensemble_Model_Predictions.xlsx")




