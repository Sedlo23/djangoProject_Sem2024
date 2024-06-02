<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <html>
    <head>
      <script type="text/javascript">
        // JavaScript function to create and download an email file
        function saveAsEmail() {
          const to = document.getElementById('to').value;
          const from = document.getElementById('from').value;
          const subject = document.getElementById('subject').value;
          const body = document.getElementById('body').value;

          if (!validateEmail(to) || !validateEmail(from)) {
            alert('Invalid email format.');
            return;
          }

          const emlContent = `To: ${to}\nFrom: ${from}\nSubject: ${subject}\nMIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\n\n${body}`;
          const blob = new Blob([emlContent], { type: 'message/rfc822' });
          const link = document.createElement('a');
          link.href = URL.createObjectURL(blob);
          link.download = 'note.eml';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        }

        // JavaScript function to validate email format
        function validateEmail(email) {
          const re = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
          return re.test(String(email).toLowerCase());
        }

        // JavaScript function to validate form inputs
        function validateForm() {
          const to = document.getElementById('to').value;
          const from = document.getElementById('from').value;
          const subject = document.getElementById('subject').value;
          const body = document.getElementById('body').value;

          if (!to || !from || !subject || !body) {
            alert('All fields are required!');
            return false;
          }

          if (!validateEmail(to) || !validateEmail(from)) {
            alert('Invalid email format.');
            return false;
          }

          return true;
        }
      </script>
    </head>
    <body>
      <h2>My Note</h2>
      <table border="1">
        <tr bgcolor="#9acd32">
          <th>To</th>
          <th>From</th>
          <th>Heading</th>
          <th>Body</th>
        </tr>
        <tr>
          <td><xsl:value-of select="note/to"/></td>
          <td><xsl:value-of select="note/from"/></td>
          <td><xsl:value-of select="note/heading"/></td>
          <td><xsl:value-of select="note/body"/></td>
        </tr>
      </table>

      <button onclick="saveAsEmail()">Save as Email</button>

      <form method="post" action="" onsubmit="return validateForm()">
        <label for="to">To:</label>
        <input type="text" id="to" name="to">
          <xsl:attribute name="value">
            <xsl:value-of select="note/to"/>
          </xsl:attribute>
        </input><br />
        <label for="from">From:</label>
        <input type="text" id="from" name="from">
          <xsl:attribute name="value">
            <xsl:value-of select="note/from"/>
          </xsl:attribute>
        </input><br />
        <label for="subject">Subject:</label>
        <input type="text" id="subject" name="subject">
          <xsl:attribute name="value">
            <xsl:value-of select="note/heading"/>
          </xsl:attribute>
        </input><br />
        <label for="body">Body:</label>
        <textarea id="body" name="body">
          <xsl:value-of select="note/body"/>
        </textarea><br />
        <input type="submit" name="phpFunction" value="Run PHP Function" />
      </form>

      <?php
        if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['phpFunction'])) {
          function phpFunction($to, $from, $subject, $body) {
            // Validate email format
            if (!filter_var($to, FILTER_VALIDATE_EMAIL) || !filter_var($from, FILTER_VALIDATE_EMAIL)) {
              echo "<p>Invalid email format.</p>";
              return;
            }

            // Advanced email handling with attachments
            $boundary = md5(uniqid(time()));
            $headers = "From: $from\r\n";
            $headers .= "Reply-To: $from\r\n";
            $headers .= "MIME-Version: 1.0\r\n";
            $headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"\r\n";

            $message = "--$boundary\r\n";
            $message .= "Content-Type: text/plain; charset=UTF-8\r\n";
            $message .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
            $message .= "$body\r\n";
            $message .= "--$boundary\r\n";

            // Example attachment (could be a file upload from form)
            $attachmentContent = "Attachment content here";
            $attachment = chunk_split(base64_encode($attachmentContent));
            $message .= "Content-Type: application/octet-stream; name=\"attachment.txt\"\r\n";
            $message .= "Content-Transfer-Encoding: base64\r\n";
            $message .= "Content-Disposition: attachment; filename=\"attachment.txt\"\r\n\r\n";
            $message .= "$attachment\r\n";
            $message .= "--$boundary--\r\n";

            if (mail($to, $subject, $message, $headers)) {
              echo "<p>Email sent successfully to $to!</p>";
            } else {
              echo "<p>Failed to send email to $to.</p>";
            }

            // Error logging
            error_log("Email sent to: $to, Subject: $subject", 3, "/var/log/php-email.log");
          }

          $to = htmlspecialchars($_POST['to']);
          $from = htmlspecialchars($_POST['from']);
          $subject = htmlspecialchars($_POST['subject']);
          $body = htmlspecialchars($_POST['body']);

          phpFunction($to, $from, $subject, $body);
        }
      ?>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
