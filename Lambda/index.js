// const AWS = require("aws-sdk");

// const s3 = new AWS.S3();
// const dynamodb = new AWS.DynamoDB.DocumentClient();
// const secretsManager = new AWS.SecretsManager();

// exports.handler = async (event) => {

//     console.log("Received Event:", JSON.stringify(event));

//     const secret = await secretsManager.getSecretValue({
//         SecretId: process.env.SECRET_NAME
//     }).promise();

//     console.log("Secret:", secret.SecretString);

//     for (const record of event.Records) {

//         const body = JSON.parse(record.body);

//         // Upload to DynamoDB
//         await dynamodb.put({
//             TableName: process.env.TABLE_NAME,
//             Item: {
//                 id: body.id,
//                 data: body
//             }
//         }).promise();

//         // Upload to S3
//         await s3.putObject({
//             Bucket: process.env.BUCKET_NAME,
//             Key: `${body.id}.json`,
//             Body: JSON.stringify(body)
//         }).promise();

//         console.log("Payload stored successfully");
//     }

//     return {
//         statusCode: 200
//     };
// };


const AWS = require("aws-sdk");

const s3 = new AWS.S3();
const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

exports.handler = async (event) => {

    try {

        console.log("Received Event:", JSON.stringify(event));

        console.log("Bucket Name:", process.env.BUCKET_NAME);

        const secret = await secretsManager.getSecretValue({
            SecretId: process.env.SECRET_NAME
        }).promise();

        console.log("Secret:", secret.SecretString);

        for (const record of event.Records) {

            console.log("Record:", record);

            const body = JSON.parse(record.body);

            console.log("Parsed Body:", body);

            // DynamoDB

            await dynamodb.put({
                TableName: process.env.TABLE_NAME,
                Item: body
            }).promise();

            console.log("Stored in DynamoDB");

            // S3 Upload

            await s3.putObject({
                Bucket: process.env.BUCKET_NAME,
                Key: `${body.id}.json`,
                Body: JSON.stringify(body),
                ContentType: "application/json"
            }).promise();

            console.log("Uploaded to S3 successfully");
        }

        return {
            statusCode: 200
        };

    } catch (error) {

        console.error("ERROR:", error);

        throw error;
    }
};