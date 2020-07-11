'use strict';

let fs = require('fs');
let path = require('path');
let AWS = require('aws-sdk-mock');
let AWS_SDK = require('aws-sdk');
AWS.setSDKInstance(AWS_SDK);

const app = require('../../app.js');

describe('XXXXXXXXXXX', function () {

    beforeEach((done) => {
        AWS.restore();
        done();
    });

    it('XXXXXXXXXXXXXXXXX', async function () {
        this.timeout(10000);

        const event = JSON.parse(fs.readFileSync(path.normalize(__dirname + '/mocks/event.json')).toString());

        try {
            await app.handler(event, context);

        } catch (err) {
            console.error(err);
            throw err;
        } finally {

        }

    });
});
