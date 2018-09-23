df = read.csv(file.choose())
dim(df)
df$state <- as.factor(df$state)
df$county <- as.factor(df$county)
df_test = read.csv(file.choose())
df_test$state <- as.factor(df_test$state)
df_test$county <- as.factor(df_test$county)
df_test
dim(df_test)

#creating model using only State information
lm_model <- lm(price2013~state, data = df)
summary(lm_model)
plot(lm_model)

#predicting housing prices using state only model
pred_state <- predict.lm(lm_model, df_test)
length(pred_state)
predict_test_state <- cbind(df_test, round(pred_state))
head(predict_test_state)

#creating model using County and State information
lm_model_2 <- lm(price2013 ~ state + county, data = df)
summary(lm_model_2)

#So, the prediction was failing since 6 counties are not present in training data. 
#Hence, the model didn't knwo what to predict for them
#Error for: factor county has new levels bossier, gilpin, grafton, harrisonburg city, hill, hunt

#to count how many mismatch rows are there
sum(!df_test$county %in% df$county)

#Changing the mismatch rows to have NA values. This will give warning that data is misleading because of 6 NA values
df_test$county[!df_test$county %in% df$county] <- NA

#predicting housing prices using County and State model
pred_state_county <- predict.lm(lm_model_2, df_test)
length(pred_state_county)
predict_test_state_county <- cbind(df_test, round(pred_state_county))
predict_test_state_county

#now in order to validate our model, I will split the training dataset into two dataset called training and validation 

size <- 0.7 * nrow(df)
intrain <- sample (nrow(df), size = size)
training <- df[intrain,]
validation <- df[-intrain,]

#training my model using training dataset and using price2007, state and poverty as the features
lm_training_model <-  lm(price2013~state  + price2007 + poverty , data = training)
summary(lm_training_model)

#predicting housing prices for validation dataset
pred <- predict.lm(lm_training_model, validation)
predict_bind <- cbind(validation, round(pred))
head(predict_bind)

#Calculating RMSE value for this validation dataset to see how good our predictive model is
sqrt(mean((predict_bind$price2013 - predict_bind$`round(pred)`)^2)) #root mean square error

#Now I will create another model using only price2007 and state as features. 
#This I am doing in order to see if poverty actually adds value to my predictive model
lm_training_model_1 <-  lm(price2013~state  + price2007, data = training)
summary(lm_training_model_1)

#predicting housing prices for validation dataset
pred_1 <- predict.lm(lm_training_model_1, validation)
predict_bind_1 <- cbind(validation, round(pred_1))
head(predict_bind_1)

#Calculating RMSE value for this validation dataset to see how good our predictive model is
sqrt(mean((predict_bind_1$price2013 - predict_bind_1$`round(pred_1)`)^2)) #root mean square error

#So, we can observe that removing poverty from the predictor value increases RMSE value and we want a model with lowest RMSe value
#Hence, in my final model I will  take price2007, state and poverty as features 

#creating final model
lm_final_model <-  lm(price2013~state +  price2007 + poverty, data = df)
summary(lm_final_model)
#predicting housing prices using final model
pred <- predict.lm(lm_final_model, df_test)
predicted_df <- cbind(df_test, round(pred))
head(predicted_df)

#we will filter the id and predicted price column and store it in a new df
predicted_final_df <- predicted_df[,c(1,7)]
#names(predicted_final_df) <- rename(predicted_df, c("round(pred)" = "price2013"))
names(predicted_final_df) <- c('id', 'prediction')

head(predicted_final_df)

#Extracting the file
write.csv(predicted_final_df, "mjha_prediction2013_1.csv")
