const cors = require('cors');
const express = require('express');
const app = express();

app.use(cors()); 
export const serverUrl = "https://i0hta7ddlf.execute-api.eu-central-1.amazonaws.com/dev";
