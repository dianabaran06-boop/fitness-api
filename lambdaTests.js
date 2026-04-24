const AWS = require("aws-sdk");
AWS.config.update({ region: "eu-central-1" });
const lambda = new AWS.Lambda();
async function testLambda(functionName, payload) {
  try {
    const response = await lambda.invoke({
      FunctionName: functionName,
      Payload: JSON.stringify(payload)
    }).promise();

    console.log(`\n=== Тест ${functionName} ===`);
    console.log("Payload:", payload);
    console.log("Result:", JSON.parse(response.Payload));
  } catch (err) {
    console.error(`Error in ${functionName}:`, err);
  }
}

//  Тести 
testLambda("get-all-trainers", {});
testLambda("get-all-workouts", {});
testLambda("get-workout", { id: "w1" });
testLambda("save-workout", {
  id: "w3",
  name: "Pilates",
  duration: 50
});
testLambda("update-workout", {
  id: "w3",
  name: "Advanced Pilates",
  duration: 55
});
testLambda("delete-workout", { id: "w3" });