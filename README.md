# Digiworks-Enterprise

This project contains the code for running Digiworks-Enterprise with <a href="https://docs.docker.com/get-started"> Docker</a> using <a href= "https://docs.docker.com/compose"> Docker Compose</a>.


## Prerequisite
<ol>
<li>
 Docker
<ul>
  This allows you to run Docker images and Docker Compose on a single computer.
 </ul>
 </li>
<li> Docker Compose
<ul>
Docker Compose is included as part of some Docker installers. If it’s not part of your installation, then install it separately after you’ve installed Docker.
</ul></li>
<li> Access to Quay
<ul> Alfresco customers can request Quay.io credentials by logging a ticket at <a href="https://support.alfresco.com/"> Alfresco Support</a>. These credentials are required to pull private (Enterprise-only) Docker images from Quay.io.
</ul>
</li>
<li> Access to Crest Dockerhub
<ul>
You can request for crest docker hub credentials by reaching out to saikat.kumar@crestsolution.com or sales@crestsolution.com, These credentials are required to pull  digiworks related changes.
</ul></li></ol>


## Technical Stack

<ol>
<li>
Alfresco Content Service v23.2.0.
</li>
<li>
Alfresco Governance Service v23.2.0.63
</li>
<li>
Elastic Search v7.10.1 
</li>
<li>
Alfresco Process Services  v24.1.0.
</li>
<li>
Allfresco Development Framework v6.10.
</li>
<li>
Angular v14.0
</li>
<li>
Alfresco Enterprise Viewer v4.0.7637.
</li>
</ol>

## Running

<ol>
<li>
Clone the repository.
</li>
<li>
Please review the compose.yml file and configure the AEV, ACS, and APS licenses as needed.
</li>
<li>
Run docker compose up.
</li>
<li>
Monitor the logs and wait for  successful startup.
</li>
</ol>

## Using

<ol>
<li>
Navigate to <a href="http://localhost:8080/share/page"> http://localhost:8080/share/page </a>and login using admin credentials.
</li>
<li>
Create a folder called <b>Admin Configuration</b> inside Repository> Data Dictionary.
</li>
<li>
Grant CONSUMER access to  GUEST user  AND EVERYONE group to the Admin Configuration folder.
</li>
<li>
Upload the <b> digiworks-statuses.json </b> file into the Admin Configuration folder.
</li>
<li>
Create a folder called <b>crestpublicLink</b> inside Repository> Data Dictionary> Email Templates.
</li>
<li>
Locate the <b>documentReminder.html.ftl </b> and <b>folderReminder.html</b> files inside the documentation folder and upload them to the crestpublicLink folder.</li>
<li>
Navigate <a href=http://localhost:8080/digiworks-enterprise> http://localhost:8080/digiworks-enterprise </a>login with admin user and change the theme for better experience. 
</li>
<li>
Follow the user manual <b>Dynamic Collaboration Workflow_Configuration_v0.1.docx</b> to configure the Activiti-App and dynamic workflow.
</li>
<li>
Follow the user manual <b>Generate Document Template_v0.1</b> to configure Document Template.
</li>
</ol>
