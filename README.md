# DigiWorks-Enterprise

DigiWorks Enterprise is the Modern, Responsive and Multi-lingual User Interface for Alfresco Digital Business Platform based on the Alfresco Application Development Framework (ADF). 

Compatible with Alfresco Content Services (ACS), Alfresco Governance Services (AGS) and Alfresco Process Services (APS), DigiWorks provides a Modern alternative user interface for Alfresco Share and Activiti App users.

This project contains the code for running Digiworks-Enterprise with <a href="https://docs.docker.com/get-started/overview/"> Docker</a> using <a href= "https://docs.docker.com/compose"> Docker Compose</a>.


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
<li> Install Alfresco Digital Business Platform
<ul> Alfresco Enterprise customers can request for <a href="https://quay.io/"> Quay.io</a> credentials by creating a support ticket at <a href="https://support.alfresco.com/"> Alfresco Support</a>. These credentials are required to pull private (Enterprise-only) Docker images from Quay.io.
</ul>
</li>
<li> Access to DigiWorks Container Images (compatible with Alfresco Digital Business platform)
<ul>
You can request DigiWorks Container Images (customised by Crest) by reaching out to sales@crestsolution.com, These credentials are required to pull  DigiWorks-related changes.
</ul></li></ol>


## Technical Stack Prerequisite

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
Alfresco Enterprise Viewer v4.1
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
Monitor the logs and wait for  a successful startup.
</li>
</ol>

## Using

<ol>
<li>
Navigate to <a href="http://localhost:8080/share/page"> http://localhost:8080/share/page </a>and login using admin credentials.
</li>
<li>
Create a folder called <b> <i> Admin Configuration</i></b> inside <b> <i> Repository> Data Dictionary </i></b>.
</li>
<li>
Grant <b> <i> CONSUMER </i></b> access to <b> <i> GUEST </i></b> user  AND <b> <i> EVERYONE </i></b> group to the Admin Configuration folder.
</li>
<li>
Upload the <b> <i>digiworks-statuses.json </i></b> file into the Admin Configuration folder.
</li>
<li>
Create a folder called <b> <i> crestpublicLink </i></b> inside Repository> Data Dictionary> Email Templates.
</li>
<li>
Locate the <b> <i> documentReminder.html.ftl </i></b> and <b> <i> folderReminder.html </i></b> files inside the documentation folder and upload them to the <b> <i> crestpublicLink </i></b> folder.</li>
<li>
Navigate <a href=http://localhost:8080/digiworks-enterprise> http://localhost:8080/digiworks-enterprise </a>login using admin credentials and go to admin tools to update the Application Theme for personalising the user experience and updating the application logo and background image etc to meet corporate branding requirements. 
</li>
<li>
Follow the user manual <b> <i> Dynamic Collaboration Workflow_Configuration_v0.1.docx </i></b> to configure the Activiti-App and dynamic workflow.
</li>
<li>
Follow the user manual <b> <i> Generate Document Template_v0.1 </i></b> to configure Document Template.
</li>
</ol>
