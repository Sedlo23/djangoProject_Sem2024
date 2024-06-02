import os
import lxml.etree as ET
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from .models import XMLData
from .forms import XMLForm
from django.conf import settings


def home(request):
    xml_data_list = XMLData.objects.all()
    return render(request, 'home.html', {'xml_data_list': xml_data_list})


from django.views.decorators.csrf import csrf_exempt
import os
from django.conf import settings
from .models import XMLData
import xml.etree.ElementTree as ET
from lxml import etree as ET_LXML

@csrf_exempt
def upload_xml(request):
    if request.method == 'POST':
        if 'file' not in request.FILES:
            return render(request, 'upload.html', {'error': 'No file was uploaded.'})

        xml_file = request.FILES['file']
        xml_content = xml_file.read().decode('utf-8')

        # Save the uploaded XML content to the database
        xml_data = XMLData(content=xml_content)
        xml_data.save()

        # Save the uploaded XML file
        xml_file_path = os.path.join(settings.MEDIA_ROOT, 'uploaded.xml')
        with open(xml_file_path, 'wb') as f:
            f.write(xml_content.encode('utf-8'))

        try:
            # Validate the XML file immediately after upload
            xsd_file_path = os.path.join(settings.MEDIA_ROOT, 'schema.xsd')
            xslt_file_path = os.path.join(settings.MEDIA_ROOT, 'transform.xsl')
            result_tree = validate_xml_file(xml_file_path, xsd_file_path, xslt_file_path)
            transformed_xml = ET_LXML.tostring(result_tree, pretty_print=True).decode('utf-8')

            # Update the transformed content in the database
            xml_data.transformed_content = transformed_xml
            xml_data.save()

            return render(request, 'validate.html', {'transformed_xml': transformed_xml, 'status': 'success'})
        except (ET.XMLSchemaError, ET_LXML.XSLTApplyError, ET.XMLSyntaxError) as e:
            xml_data.transformed_content = "ERROR in Validation"
            xml_data.save()
            return render(request, 'validate.html', {'error': str(e), 'status': 'error'})

    return render(request, 'upload.html')


def validate_xml(request):
    xml_file_path = os.path.join(settings.MEDIA_ROOT, 'uploaded.xml')
    xsd_file_path = os.path.join(settings.MEDIA_ROOT, 'schema.xsd')
    xslt_file_path = os.path.join(settings.MEDIA_ROOT, 'transform.xsl')

    try:
        result_tree = validate_xml_file(xml_file_path, xsd_file_path, xslt_file_path)
        transformed_xml = ET.tostring(result_tree, pretty_print=True).decode('utf-8')
        return render(request, 'validate.html', {'transformed_xml': transformed_xml, 'status': 'success'})
    except (ET.XMLSchemaError, ET.XSLTApplyError, ET.XMLSyntaxError) as e:
        return render(request, 'validate.html', {'error': str(e), 'status': 'error'})


def validate_xml_file(xml_file_path, xsd_file_path, xslt_file_path):
    # Parse the XML file
    xml_tree = ET.parse(xml_file_path)

    # Parse the XSD file
    xsd_tree = ET_LXML.parse(xsd_file_path)
    xsd_schema = ET_LXML.XMLSchema(xsd_tree)

    # Validate the XML against the XSD schema
    if not xsd_schema.validate(ET_LXML.fromstring(ET.tostring(xml_tree.getroot()))):
        raise ET.XMLSchemaError("XML validation failed against the XSD schema.")

    # Parse the XSLT file
    xslt_tree = ET_LXML.parse(xslt_file_path)
    xslt_transformer = ET_LXML.XSLT(xslt_tree)

    # Transform the XML using the XSLT
    result_tree = xslt_transformer(ET_LXML.fromstring(ET.tostring(xml_tree.getroot())))

    return result_tree
def get_root_element_name(xsd_file_path):
    tree = ET.parse(xsd_file_path)
    root = tree.getroot()
    element = root.find('.//xs:element', namespaces={'xs': 'http://www.w3.org/2001/XMLSchema'})
    return element.get('name') if element is not None else None

def create_xml(request):
    xsd_file_path = os.path.join(settings.MEDIA_ROOT, 'schema.xsd')

    if request.method == 'POST':
        form = XMLForm(request.POST, xsd_file=xsd_file_path)
        if form.is_valid():
            root_element_name = get_root_element_name(xsd_file_path)
            if root_element_name is None:
                form.add_error(None, "Root element not found in XSD schema.")
            else:
                xml_data = ET.Element(root_element_name)
                for field, value in form.cleaned_data.items():
                    ET.SubElement(xml_data, field).text = value

                xml_string = ET.tostring(xml_data, pretty_print=True).decode('utf-8')

                # Validate the XML content against the XSD schema
                schema_root = ET.parse(xsd_file_path).getroot()
                schema = ET.XMLSchema(schema_root)
                xml_doc = ET.XML(xml_string)

                try:
                    schema.assertValid(xml_doc)
                    # Save the XML content to the database
                    xml_entry = XMLData(content=xml_string)
                    xml_entry.save()

                    return redirect('home')
                except ET.DocumentInvalid as e:
                    form.add_error(None, f"XML Schema validation error: {str(e)}")

    else:
        form = XMLForm(xsd_file=xsd_file_path)

    return render(request, 'create_xml.html', {'form': form})
