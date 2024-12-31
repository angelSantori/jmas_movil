import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jmas_movil/widgets/mensajes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

//ListTitle
class CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

//ExpansionTitle
class CustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: children,
      ),
    );
  }
}

//SubExpansionTitle
class SubCustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SubCustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
          collapsedIconColor: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: children,
        ),
      ),
    );
  }
}

//Buscar producto
class BuscarProductoWidget extends StatelessWidget {
  final TextEditingController idProductoController;
  final TextEditingController cantidadController;
  final productosController;
  final bool isLoading;
  final dynamic selectedProducto;
  final Function(dynamic) onProductoSeleccionado;
  final Function(String) onAdvertencia;

  const BuscarProductoWidget({
    Key? key,
    required this.idProductoController,
    required this.cantidadController,
    required this.productosController,
    required this.isLoading,
    required this.selectedProducto,
    required this.onProductoSeleccionado,
    required this.onAdvertencia,
  }) : super(key: key);

  void _openScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escanee código'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              if (barcode.rawValue != null) {
                idProductoController.text = barcode.rawValue!;
                Navigator.pop(context);
                _buscarProducto();
              }
            },
          ),
        ),
      ),
    );
  }

  void _buscarProducto() async {
    final id = idProductoController.text;
    if (id.isNotEmpty) {
      onProductoSeleccionado(null); // Limpiar el producto antes de buscar
      final producto = await productosController.getProductoById(int.parse(id));
      if (producto != null) {
        onProductoSeleccionado(producto);
      } else {
        onAdvertencia('Producto con ID: $id, no encontrado');
      }
    } else {
      onAdvertencia('Por favor, ingrese un ID de producto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Añadir un SingleChildScrollView para que sea desplazable en móviles
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Campo para ID del Producto
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: idProductoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ID del Producto',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isLoading && idProductoController.text.isEmpty
                        ? Colors.red
                        : Colors.blue.shade900,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ),

          // Botón para buscar producto y QR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                //Scanner
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  color: Colors.blue.shade900,
                  onPressed: () {
                    _openScanner(context);
                  },
                ),
                //Buscar producto
                ElevatedButton(
                  onPressed: () {
                    _buscarProducto();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                  ),
                  child: const Text(
                    'Buscar producto',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información del Producto
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (selectedProducto != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información del Producto:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Descripción: ${selectedProducto!.producto_Descripcion ?? 'No disponible'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Precio: \$${selectedProducto!.producto_Precio1?.toStringAsFixed(2) ?? 'No disponible'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Existencia: ${selectedProducto!.producto_Existencia ?? 'No disponible'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No se ha buscado un producto.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),

          // Campo para la cantidad
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                TextFormField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isLoading && cantidadController.text.isEmpty
                            ? Colors.red
                            : Colors.blue.shade900,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Tabla de productos
Widget tablaProductosAgregados(List<Map<String, dynamic>> productosAgregados) {
  if (productosAgregados.isEmpty) {
    return const Text(
      'No hay productos agregados.',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Table(
        border: TableBorder.all(),
        columnWidths: const {
          0: FlexColumnWidth(1.6), //ID
          1: FlexColumnWidth(3), //Descripción
          2: FlexColumnWidth(2), //Costo
          3: FlexColumnWidth(2.2), //Cantidad
          4: FlexColumnWidth(3), //Total
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Clave',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Descripción',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Costo',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Cantidad',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Precio',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ...productosAgregados.map((producto) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['id'].toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['descripcion'] ?? 'Sin descripción'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$${producto['costo'].toString()}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(producto['cantidad'].toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$${producto['precio'].toStringAsFixed(2)}'),
                ),
              ],
            );
          }),
          TableRow(children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\$${productosAgregados.fold<double>(0.0, (previousValue, producto) => previousValue + (producto['precio'] ?? 0.0)).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ])
        ],
      ),
    ],
  );
}

//Validación
Future<bool> validarCamposAntesDeImprimir({
  required BuildContext context,
  required List productosAgregados,
  required TextEditingController referenciaController,
  required var selectedProveedor,
  required var selectedEntidad,
  required var selectedJunta,
  required var selectedUser,
}) async {
  if (productosAgregados.isEmpty) {
    showAdvertence(context, 'Debe agregar productos antes de imprimir.');
    return false;
  }

  if (referenciaController.text.isEmpty) {
    showAdvertence(context, 'La referencia es obligatoria.');
    return false;
  }

  if (selectedProveedor == null) {
    showAdvertence(context, 'Debe seleccionar un proveedor.');
    return false;
  }

  if (selectedEntidad == null) {
    showAdvertence(context, 'Debe seleccionar una entidad.');
    return false;
  }

  if (selectedJunta == null) {
    showAdvertence(context, 'Debe seleccionar una junta.');
    return false;
  }

  if (selectedUser == null) {
    showAdvertence(context, 'Debe seleccionar un usuario.');
    return false;
  }

  return true; // Si pasa todas las validaciones, los datos están completos
}

//PDF
Future<void> generateAndPrintPdf({
  required BuildContext context,
  required String movimiento,
  required String fecha,
  required String referencia,
  required String proveedor,
  required String entidad,
  required String junta,
  required String usuario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
  );

  // Obtener tamaño dinámico para dispositivos móviles
  final pageFormat = PdfPageFormat(
    210 * PdfPageFormat.mm, // A4 width in mm
    297 * PdfPageFormat.mm, // A4 height in mm
  );

  // Generar contenido del PDF
  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de $movimiento',
                style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Text('Fecha: $fecha'),
            pw.Text('Referencia: $referencia'),
            pw.Text('Proveedor: $proveedor'),
            pw.Text('Entidad: $entidad'),
            pw.Text('Junta: $junta'),
            pw.Text('Usuario: $usuario'),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['Clave', 'Descripción', 'Costo', 'Cantidad', 'Total'],
              data: productos.map((producto) {
                return [
                  producto['id'].toString(),
                  producto['descripcion'] ?? '',
                  '\$${producto['costo'].toString()}',
                  producto['cantidad'].toString(),
                  '\$${producto['precio'].toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        );
      },
    ),
  );

  try {
    // Para dispositivos móviles, usamos FilePicker para seleccionar la carpeta
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // El usuario canceló la selección
      return;
    }

    // Generar nombre del archivo con la fecha actual
    final String currentDate = DateFormat('ddMMyyyy').format(DateTime.now());
    final String currentTime = DateFormat('HHmmss').format(DateTime.now());
    final String fileName = 'entrada_reporte_${currentDate}_$currentTime.pdf';

    // Construir la ruta completa del archivo
    final String filePath = '$selectedDirectory/$fileName';

    // Guardar el archivo PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // ignore: avoid_print
    print('PDF guardado en: $filePath');

    // Mostrar vista previa e imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error al guardar el PDF: $e');
  }
}

bool isPermissionRequested = false;

Future<void> requestStoragePermission() async {
  if (isPermissionRequested) return; // Evitar solicitudes simultáneas.

  isPermissionRequested = true;

  try {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      print('Permiso concedido');
    } else if (status.isPermanentlyDenied) {
      print('Permiso permanentemente denegado');
      openAppSettings(); // Abre la configuración para que el usuario permita el permiso manualmente.
    } else {
      print('Permiso denegado');
    }
  } catch (e) {
    print('Error al solicitar permiso: $e');
  }

  isPermissionRequested = false;
}

Future<void> generateAndSavePdf({
  required BuildContext context,
  required String movimiento,
  required String fecha,
  required String referencia,
  required String proveedor,
  required String entidad,
  required String junta,
  required String usuario,
  required List<Map<String, dynamic>> productos,
}) async {
  final pdf = pw.Document();

  // Cálculo del total
  final total = productos.fold<double>(
    0.0,
    (sum, producto) => sum + (producto['precio'] ?? 0.0),
  );

  // Crear el PDF
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Align(
              alignment: pw.Alignment.center, // Centra el título
              child: pw.Text(
                'Reporte de $movimiento',
                style: const pw.TextStyle(fontSize: 18),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Fecha: $fecha',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.Text(
              'Referencia: $referencia',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.Text(
              'Proveedor: $proveedor',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.Text(
              'Entidad: $entidad',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.Text(
              'Junta: $junta',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.Text(
              'Usuario: $usuario',
              textAlign: pw.TextAlign.left, // Alineación a la izquierda
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['Clave', 'Descripción', 'Costo', 'Cantidad', 'Total'],
              data: productos.map((producto) {
                return [
                  producto['id'].toString(),
                  producto['descripcion'] ?? '',
                  '\$${producto['costo'].toString()}',
                  producto['cantidad'].toString(),
                  '\$${producto['precio'].toStringAsFixed(2)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Total: \$${total.toStringAsFixed(2)}'),
          ],
        );
      },
    ),
  );

  try {
    // Esperar a que el permiso se haya concedido antes de continuar.
    await requestStoragePermission();

    // Obtener la ruta del almacenamiento
    final directory = Directory('/storage/emulated/0/Download');

    if (!await directory.exists()) {
      print('La carpeta Descargas no existe.');
      return;
    }

    final String directoryPath = directory.path;

    // Obtener la fecha y hora actual
    final currentTime = DateTime.now();
    final formattedDate = DateFormat('ddMMyyyy_HHmmss').format(currentTime);

    // Definir el nombre del archivo PDF
    final fileName = '${movimiento}_reporte_$formattedDate.pdf';
    final filePath = '$directoryPath/$fileName';

    // Guardar el archivo PDF en la carpeta predeterminada
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print('PDF guardado en: $filePath');
    showOk(context, 'PDF guardado en la carpeta Download');
  } catch (e) {
    print('Error al guardar el PDF: $e');
  }
}
