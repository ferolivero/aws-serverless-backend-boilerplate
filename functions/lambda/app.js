const axios = require('axios');
const url = 'http://checkip.amazonaws.com/';
let response;

/**
 *
 * @param event
 * @param context
 * @returns {Promise<*>}
 */

exports.handler = async (event, context) => {
    console.log('ESTO ES UN MENSAJE DESDE LA LAYER CUSTOM logger');
    try {
        const ret = await axios(url);
        response = {
            statusCode: 200,
            body: JSON.stringify({
                message: 'hello world',
                location: ret.data.trim(),
            }),
        };
    } catch (err) {
        console.error(err);
        response = {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error',
            }),
        };
    }

    return response;
};
