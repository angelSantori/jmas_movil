import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jmas_movil/controllers/productos_controller.dart';

class DetailsProductoScreen extends StatelessWidget {
  final Productos producto;

  const DetailsProductoScreen({Key? key, required this.producto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.producto_Descripcion ?? 'Detalles del producto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: producto.producto_ImgBase64 != null &&
                          producto.producto_ImgBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(producto.producto_ImgBase64!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/sinFoto.jpg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Clave de producto: ${producto.id_Producto}',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descripción: ${producto.producto_Descripcion}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Costo: \$${producto.producto_Costo}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Unidad de medida: ${producto.producto_UMedida}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Precio 1: \$${producto.producto_Precio1}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Precio 2: \$${producto.producto_Precio2}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Precio 3: \$${producto.producto_Precio3}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Existencias: ${producto.producto_Existencia} ${producto.producto_UMedida}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Existencias iniciales: ${producto.producto_ExistenciaInicial} ${producto.producto_UMedida}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Existencias conteo físico: ${producto.producto_ExistenciaConFis} ${producto.producto_UMedida}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: producto.producto_QR64 != null &&
                          producto.producto_QR64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(producto.producto_QR64!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/sinQr.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
