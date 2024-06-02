from django import forms
import lxml.etree as ET

class XMLForm(forms.Form):
    def __init__(self, *args, **kwargs):
        xsd_file = kwargs.pop('xsd_file', None)
        super(XMLForm, self).__init__(*args, **kwargs)

        if xsd_file:
            schema_root = ET.parse(xsd_file).getroot()
            self._parse_schema(schema_root)

    def _parse_schema(self, schema_root):
        root_element = schema_root.find('.//xs:element', namespaces={'xs': 'http://www.w3.org/2001/XMLSchema'})
        complex_type = root_element.find('.//xs:complexType', namespaces={'xs': 'http://www.w3.org/2001/XMLSchema'})
        sequence = complex_type.find('.//xs:sequence', namespaces={'xs': 'http://www.w3.org/2001/XMLSchema'})
        for element in sequence.findall('xs:element', namespaces={'xs': 'http://www.w3.org/2001/XMLSchema'}):
            name = element.get('name')
            if name:
                self.fields[name] = forms.CharField(label=name.capitalize(), max_length=255)
