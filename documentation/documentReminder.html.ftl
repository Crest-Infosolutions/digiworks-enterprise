<html>
	<body style="background-color: #e8edf1; padding: 0; margin: 0;">
		<table width="100%" height="400" cellpadding="0" cellspacing="0" style="margin:0; padding:0">
			<tr height="50"><td colspan="3"></td></tr>
			<tr>
				<td width="10%"></td>
				<td width="80%" valign="top" >
					<table style="background-color: #fff;padding: 0px;" width="100%" cellpadding="0" cellspacing="0">
						<tr height="30"><td colspan="3"></td></tr>
						<tr>
							<td width="15"></td>
							<td valign="center"style="font-size: 16px;font-family: 'Open Sans', Helvetica, sans-serif; font-weight: bold; ">Instructions on Shared Document</td>
							<td width="15"></td>
						</tr>
						<tr height="30"><td colspan="3"></td></tr>
						<tr height="1" style="background-color: #e8edf1;"><td colspan="3"></td></tr>
						
						<tr>
							<td width="30"></td>
							<td valign="top" style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">
							<!-- <pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;padding-top: 50px;">Hi User, </pre>  -->
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Please see the details of the shared document:</pre>
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Document Name: <strong>${documentName}</strong></pre>
							<#if documentTitle??>
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Document Title: <strong>${documentTitle}</strong></pre>
							</#if>
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Public URL of the document: <strong>${publicUrl}</strong></pre>
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Expiry date of public URL of the document:<strong> ${expiryDate}</strong></pre>
							<pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">Password to access the document by the External User:<strong>${password}</strong></pre>
							<br/><br><pre style="font-size: 14px;font-family: 'Open Sans', Helvetica, sans-serif;">To view the shared document, please click on the button below</pre>
							
							
							</td>
							<td width="15"></td>
						</tr>
						<tr height="30"><td colspan="3"></td></tr>
						<tr>
							<td width="15"></td>
							<td valign="top">
								<table style="background-color: #ffffff;" width="100%" cellpadding="0" cellspacing="0">
									<tr>
										<td valign="middle" style="font-size: 15px;font-family: 'Open Sans', Helvetica, sans-serif; text-align: left; font-weight: bold;  color: #ffffff;">
											<a href="${publicUrl}"title="view shared item" style="text-decoration: none; text-align: center;color: #ffffff; display: inline-block; width: 300px; padding: 10px 0px;background-color: #2A85FF; border-radius: 10px; -moz-border-radius: 10px; -webkit-border-radius: 10px;">View Shared Document</a>
										</td>
									</tr>
								</table>
							</td>
							<td width="15"></td>
						</tr>
						
						<tr height="25"><td colspan="3"></td></tr>
					</table>
				</td>
				<td width="10%"></td>
			</tr>
		</table>
	</body>
</html>