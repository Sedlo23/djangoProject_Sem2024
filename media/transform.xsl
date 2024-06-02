<documents>
    <document index="1">
        <source>
        paste.txt</source>
        <document_content>
            <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:output method="html"/>
                <xsl:template match="/">
                    <html>
                    <head>
                        <script type="text/javascript">
                            // Funkce v JavaScriptu pro vytvoření a stažení souboru e-mailu
                            function saveAsEmail() {
                                const to = document.getElementById('to').value;
                                const from = document.getElementById('from').value;
                                const subject = document.getElementById('subject').value;
                                const body = document.getElementById('body').value;
                                if (!validateEmail(to) || !validateEmail(from)) {
                                    alert('Neplatný formát e-mailu.');
                                    return;
                                }
                                Copy
                                code
                                const emlContent = `To: ${to}\nFrom: ${from}\nSubject: ${subject}\nMIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\n\n${body}`;
                                const blob = new Blob([emlContent], {type: 'message/rfc822'});
                                const link = document.createElement('a');
                                link.href = URL.createObjectURL(blob);
                                link.download = 'note.eml';
                                document.body.appendChild(link);
                                link.click();
                                document.body.removeChild(link);
                            }


                            function validateEmail(email) {
                                const re = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
                                return re.test(String(email).toLowerCase());
                            }


                            function validateForm() {
                                const to = document.getElementById('to').value;
                                const from = document.getElementById('from').value;
                                const subject = document.getElementById('subject').value;
                                const body = document.getElementById('body').value;

                                if (!to || !from || !subject || !body) {
                                    alert('Všechna pole jsou povinná!');
                                    return false;
                                }

                                if (!validateEmail(to) || !validateEmail(from)) {
                                    alert('Neplatný formát e-mailu.');
                                    return false;
                                }

                                return true;
                            }
                        </script>
                    </head>
                    <body>
                    <h2>Moje poznámka</h2>
                    <table border="1">
                        <tr bgcolor="#9acd32">
                            <th>Komu</th>
                            <th>Od</th>
                            <th>Předmět</th>
                            <th>Tělo</th>
                        </tr>
                        <tr>
                            <td>
                                <xsl:value-of select="note/to"/>
                            </td>
                            <td>
                                <xsl:value-of select="note/from"/>
                            </td>
                            <td>
                                <xsl:value-of select="note/heading"/>
                            </td>
                            <td>
                                <xsl:value-of select="note/body"/>
                            </td>
                        </tr>
                    </table>
                    <button onclick="saveAsEmail()">Uložit jako e-mail</button>
                    <form method="post" action="" onsubmit="return validateForm()" enctype="multipart/form-data">
                        {% csrf_token %}
                        <label for="to">Komu:</label>
                        <input type="text" id="to" name="to" value="{note/to}"/><br/>
                        <label for="from">Od:</label>
                        <input type="text" id="from" name="from" value="{note/from}"/><br/>
                        <label for="subject">Předmět:</label>
                        <input type="text" id="subject" name="subject" value="{note/heading}"/><br/>
                        <label for="body">Tělo:</label>
                        <textarea id="body" name="body"><xsl:value-of select="note/body"/></textarea><br/>
                        <input type="submit" name="submit" value="Aktualizovat XML"/>
                    </form>
                    <?php
if(isset($_POST['submit'])) {
  $to = trim($_POST['to']);
  $from = trim($_POST['from']);
  $subject = trim($_POST['subject']);
  $body = trim($_POST['body']);
// Validace vstupů formuláře
$errors = array();
if(empty($to)) {
$errors[] = "Pole 'Komu' je povinné.";
} elseif(!filter_var($to, FILTER_VALIDATE_EMAIL)) {
$errors[] = "Neplatný formát e-mailu pro pole 'Komu'.";
}
if(empty($from)) {
$errors[] = "Pole 'Od' je povinné.";
} elseif(!filter_var($from, FILTER_VALIDATE_EMAIL)) {
$errors[] = "Neplatný formát e-mailu pro pole 'Od'.";
}
if(empty($subject)) {
$errors[] = "Pole 'Předmět' je povinné."; }
if(empty($body)) {
$errors[] = "Pole 'Tělo' je povinné.";
}
if(empty($errors)) {
Copy code$xml = simplexml_load_file('note.xml');


$backup_file = 'note_backup_' . date('YmdHis') . '.xml';
$xml->asXML($backup_file);


                    $xml->to = $to;
                    $xml->from = $from;
                    $xml->heading = $subject;
                    $xml->body = $body;


                    if($xml->asXML('note.xml')) {
                    $success_msg = "XML soubor byl úspěšně aktualizován.";
                    } else {
                    $errors[] = "Nepodařilo se aktualizovat XML soubor."; }
                    }
                    }
                    ?>
                    <!-- Zobrazení zprávy o úspěchu nebo chybových zpráv -->
                    <?php if(isset($success_msg)): ?>
                    <p style="color: green;"><?php echo $success_msg; ?></p>
                    <?php elseif(!empty($errors)): ?>
                    <ul style="color: red;">
                        <?php foreach($errors as $error): ?>
                        <li><?php echo $error; ?></li>
                        <?php endforeach; ?>
                    </ul>
                    <?php endif; ?>
                    </body>
                    </html>
                </xsl:template>
            </xsl:stylesheet>
        </document_content>
    </document>
</documents>