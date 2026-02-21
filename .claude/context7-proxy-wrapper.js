// context7-proxy-wrapper.js
// Patches Node.js native fetch to use HTTPS_PROXY via undici ProxyAgent
const { ProxyAgent, setGlobalDispatcher } = require('undici');

const proxy = process.env.HTTPS_PROXY || process.env.HTTP_PROXY;
if (proxy) {
  setGlobalDispatcher(new ProxyAgent(proxy));
}

require('C:/Users/19132/AppData/Roaming/npm/node_modules/@upstash/context7-mcp/dist/index.js');
