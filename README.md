<p align="center">
  <img src="https://github.com/Crest-Infosolutions/digiworks-enterprise/blob/main/resources/logo_digiworks.png?raw=true" alt="DigiWorks Logo" width="200"/>
</p>

<p align="center">
  <strong style="font-size: 24px;">DigiWorks Enterprise</strong>
</p>

---






<p><strong>DigiWorks Enterprise</strong> is a <strong>modern, responsive, and multilingual user interface</strong> for the <strong>Alfresco Digital Business Platform</strong>, built using the <strong>Alfresco Application Development Framework (ADF)</strong>.</p>

<p>It provides a sleek, user-friendly alternative to <strong>Alfresco Share</strong> and <strong>Activiti App</strong>, and is compatible with:</p>

<ul>
  <li>✅ <strong>Alfresco Content Services (ACS)</strong></li>
  <li>✅ <strong>Alfresco Governance Services (AGS)</strong></li>
  <li>✅ <strong>Alfresco Process Services (APS)</strong></li>
</ul>

<p>This repository includes all necessary code to run DigiWorks Enterprise using <a href="https://docs.docker.com/get-started/overview/">Docker</a> and <a href="https://docs.docker.com/compose">Docker Compose</a>.</p>

<hr>

<h2>🧰 Prerequisites</h2>

<p>Ensure the following are installed and available before running the project:</p>

<ol>
  <li>🐳 <strong>Docker</strong><br>
    <small>Allows you to run containers locally.</small>
  </li>
  <li>🧩 <strong>Docker Compose</strong><br>
    <small>Included in some Docker installations, or <a href="https://docs.docker.com/compose/install/">install separately</a>.</small>
  </li>
  <li>🏢 <strong>Alfresco Digital Business Platform</strong><br>
    <small>Request Enterprise Docker image credentials via a support ticket at <a href="https://support.alfresco.com/">Alfresco Support</a>. Images are hosted on <a href="https://quay.io/">Quay.io</a>.</small>
  </li>
  <li>📦 <strong>DigiWorks Container Images (by Crest)</strong><br>
    <small>Request access by emailing <a href="mailto:sales@crestsolution.com">sales@crestsolution.com</a> to obtain credentials for pulling the custom DigiWorks containers.</small>
  </li>
</ol>

<hr>

<h2>🧱 Technical Stack Compatibility</h2>

<table>
  <thead>
    <tr><th>Component</th><th>Version</th></tr>
  </thead>
  <tbody>
    <tr><td>Alfresco Content Services</td><td>v25.1.0</td></tr>
    <tr><td>Alfresco Governance Services</td><td>v25.1.0.60</td></tr>
    <tr><td>Alfresco Process Services</td><td>v25.1.1</td></tr>
    <tr><td>ElasticSearch</td><td>v8.17.6</td></tr>
    <tr><td>Alfresco Development Framework</td><td>v6.10</td></tr>
    <tr><td>Angular</td><td>v14.0</td></tr>
    <tr><td>Alfresco Enterprise Viewer</td><td>v4.2.0</td></tr>
  </tbody>
</table>

<hr>

<h2>▶️ Getting Started</h2>

<h3>🛠️ Setup Instructions</h3>

<ol>
  <li><strong>Clone the repository</strong>
    <pre><code>git clone https://github.com/Crest-Infosolutions/digiworks-enterprise.git &&
cd digiWorks-enterprise</code></pre>
  </li>

  <li><strong>Configure Licenses</strong><br>
  Place valid licenses for AEV, ACS, and APS inside the resources folder.</li>

  <li><strong>Update Endpoint URLs</strong><br>
  Modify <code>resources/aps.sh</code> and <code>resources/acs.sh</code> with your environment-specific URLs.
  <br><em>(Skip this step if running on localhost)</em></li>

  <li><strong>(Optional) Replace Google API Key</strong><br>
  Replace the Gemini API key (<code>AIzaSyByR5...</code>) in <code>compose.yml</code> with your own <a href="https://makersuite.google.com/app/apikey">Google AI Studio</a> key.</li>

  <li><strong>(Optional) Enable Digital Signature Integration</strong><br>
  Ensure ACS is publicly accessible, then update the following properties in <code>resources/alfresco-global.properties</code>:
    <ul>
      <li><code>digisign.alfresco.url:{Public IP of ACS}</code></li>
      <li><code>digisign.alfresco.port:{PORT}</code></li>
      <li><code>digisign.alfresco.protocol:{hhtp/https}</code></li>
    </ul>
  </li>

  <li><strong>Start the environment</strong>
    <pre><code>docker compose up</code></pre>
  </li>

  <li><strong>Wait for successful container startup</strong><br>
  Monitor logs to ensure all services are running.</li>
</ol>

<hr>

<h2>🧪 Accessing the System</h2>

<table>
  <thead>
    <tr><th>Interface</th><th>URL</th><th>Credentials</th></tr>
  </thead>
  <tbody>
    <tr>
      <td>DigiWorks UI</td>
      <td><a href="http://localhost:8080/digiworks-enterprise">http://localhost:8080/digiworks-enterprise</a></td>
      <td>johndoe@crestsolution.com / Crest@123</td>
    </tr>
    <tr>
      <td>Alfresco Share</td>
      <td><a href="http://localhost:8080/share">http://localhost:8080/share</a></td>
      <td>admin / admin</td>
    </tr>
    <tr>
      <td>APS (Activiti App)</td>
      <td><a href="http://localhost:8080/activiti-app">http://localhost:8080/activiti-app</a></td>
      <td>admin@app.activiti.com / admin</td>
    </tr>
  </tbody>
</table>

<hr>

<h2>📬 Support</h2>

<p>For issues or enterprise inquiries, contact <a href="mailto:sales@crestsolution.com">sales@crestsolution.com</a>.</p>
