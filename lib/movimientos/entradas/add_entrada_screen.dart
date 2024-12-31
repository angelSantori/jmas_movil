import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmas_movil/controllers/entidades_controller.dart';
import 'package:jmas_movil/controllers/entradas_controller.dart';
import 'package:jmas_movil/controllers/juntas_controller.dart';
import 'package:jmas_movil/controllers/productos_controller.dart';
import 'package:jmas_movil/controllers/proveedores_controller.dart';
import 'package:jmas_movil/controllers/users_controller.dart';
import 'package:jmas_movil/widgets/componentes.dart';
import 'package:jmas_movil/widgets/mensajes.dart';

class AddEntradaScreen extends StatefulWidget {
  const AddEntradaScreen({super.key});

  @override
  State<AddEntradaScreen> createState() => _AddEntradaScreenState();
}

class _AddEntradaScreenState extends State<AddEntradaScreen> {
  final EntradasController _entradasController = EntradasController();
  final UsersController _usersController = UsersController();
  final JuntasController _juntasController = JuntasController();
  final EntidadesController _entidadesController = EntidadesController();
  final ProductosController _productosController = ProductosController();
  final ProveedoresController _proveedoresController = ProveedoresController();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _idProductoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  final String _fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

  List<Users> _users = [];
  List<Entidades> _entidades = [];
  List<Juntas> _juntas = [];
  List<Proveedores> _proveedores = [];
  final List<Map<String, dynamic>> _productosAgregados = [];

  Users? _selectedUser;
  Entidades? _selectedEntidad;
  Juntas? _selectedJunta;
  Productos? _selectedProducto;
  Proveedores? _selectedProveedor;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntidades();
    _loadJuntas();
    _loadUsers();
    _loadProveedores();
  }

  Future<void> _loadEntidades() async {
    List<Entidades> entidades = await _entidadesController.listEntidades();
    setState(() {
      _entidades = entidades;
    });
  }

  Future<void> _loadJuntas() async {
    List<Juntas> juntas = await _juntasController.listJuntas();
    setState(() {
      _juntas = juntas;
    });
  }

  Future<void> _loadUsers() async {
    List<Users> users = await _usersController.listUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _loadProveedores() async {
    List<Proveedores> proveedores =
        await _proveedoresController.listProveedores();
    setState(() {
      _proveedores = proveedores;
    });
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _cantidadController.text.isNotEmpty) {
      final int cantidad = int.tryParse(_cantidadController.text) ?? 0;

      if (cantidad <= 0) {
        showAdvertence(context, 'La cantidad debe ser mayor a 0.');
        return;
      }

      setState(() {
        final double precioUnitario =
            _selectedProducto!.producto_Precio1 ?? 0.0;
        final double precioTotal = precioUnitario * cantidad;

        _productosAgregados.add({
          'id': _selectedProducto!.id_Producto,
          'descripcion': _selectedProducto!.producto_Descripcion,
          'costo': _selectedProducto!.producto_Precio1,
          'cantidad': cantidad,
          'precio': precioTotal
        });

        //Limpiar campos despuués de agregar
        _idProductoController.clear();
        _cantidadController.clear();
        _selectedProducto = null;
      });
    } else {
      showAdvertence(
          context, 'Debe seleccionar un producto y definir la cantidad.');
    }
  }

  Future<void> _guardarEntrada() async {
    if (_productosAgregados.isEmpty) {
      showAdvertence(
          context, 'Debe agregar productos antes de guardar la entrada.');
      return;
    }
    if (_formKey.currentState!.validate()) {
      bool success = true; // Para verificar si al menos una entrada fue exitosa
      for (var producto in _productosAgregados) {
        final nuevaEntrada = _crearEntrada(producto);
        bool result = await _entradasController.addEntrada(nuevaEntrada);

        if (!result) {
          success = false;
          break; // Si hay error, no procesamos más productos y mostramos el error
        }

        if (producto['id'] == null) {
          showAdvertence(context,
              'Id nulo: ${producto['id_Producto']}, no se puede continuar');
          success = false;
          break;
        }

        final productoActualizado =
            await _productosController.getProductoById(producto['id']);

        if (productoActualizado == null) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Producto con ID ${producto['id']} no encontrado en la base de datos.');
          success = false;
          break;
        }

        productoActualizado.producto_Existencia =
            (productoActualizado.producto_Existencia!) + producto['cantidad'];

        bool editResult =
            await _productosController.editProducto(productoActualizado);

        if (!editResult) {
          // ignore: use_build_context_synchronously
          showAdvertence(context,
              'Error al actualizar las existencias del producto con ID ${producto['id_Producto']}');
          success = false;
          break;
        }
      }

      // Mostrar el mensaje correspondiente al finalizar el ciclo
      if (success) {
        // ignore: use_build_context_synchronously
        showOk(context, 'Entrada creada exitosamente.');
      } else {
        // ignore: use_build_context_synchronously
        showError(context, 'Error al registrar entradas');
      }

      _limpiarFormulario(); // Limpiar formulario después de guardar
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    _productosAgregados.clear();
    setState(() {
      _selectedUser = null;
      _selectedEntidad = null;
      _selectedJunta = null;
      _selectedProducto = null;
      _selectedProveedor = null;
      _referenciaController.clear();
      _idProductoController.clear();
      _cantidadController.clear();
    });
  }

  Entradas _crearEntrada(Map<String, dynamic> producto) {
    return Entradas(
      id_Entradas: 0,
      entrada_Folio: _referenciaController.text,
      entrada_Unidades: double.tryParse(producto['cantidad'].toString()),
      entrada_Costo: double.tryParse(producto['precio'].toString()),
      entrada_Fecha: _fecha,
      id_Producto: producto['id'] ?? 0, // Toma el id del producto de la lista
      id_Proveedor: _selectedProveedor?.id_Proveedor ?? 0, // Proveedor
      id_User: _selectedUser?.id_User ?? 0, // Usuario
      id_Junta: _selectedJunta?.id_Junta ?? 0, // Junta
      id_Entidad: _selectedEntidad?.id_Entidad ?? 0, // Entidad
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Entrada'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  //Fecha
                  Text(
                    _fecha,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Referencia
                  buildFormColumn(
                    label: 'Referencia',
                    child: TextFormField(
                      controller: _referenciaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Referencia requerida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  //Proveedores
                  buildFormColumn(
                    label: 'Proveedor',
                    child: DropdownButtonFormField<Proveedores>(
                      value: _selectedProveedor,
                      items: _proveedores
                          .map((proveedor) => DropdownMenuItem(
                                value: proveedor,
                                child: Text(proveedor.proveedor_Name!),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProveedor = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Proveedor requerido.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  //Entidad
                  buildFormColumn(
                    label: 'Entidad',
                    child: DropdownButtonFormField<Entidades>(
                      value: _selectedEntidad,
                      items: _entidades
                          .map((entidad) => DropdownMenuItem(
                                value: entidad,
                                child: Text(
                                    entidad.entidad_Nombre ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEntidad = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Entidad requerida.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  //Junta
                  buildFormColumn(
                    label: 'Junta',
                    child: DropdownButtonFormField<Juntas>(
                      value: _selectedJunta,
                      items: _juntas
                          .map((junta) => DropdownMenuItem(
                                value: junta,
                                child: Text(junta.junta_Name ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJunta = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Junta requerida.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  //Usuario
                  //Users
                  buildFormColumn(
                    label: 'Usuario:',
                    child: DropdownButtonFormField<Users>(
                      value: _selectedUser,
                      items: _users
                          .map((user) => DropdownMenuItem(
                                value: user,
                                child: Text(user.user_Name ?? 'Sin Nombre'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Debe seleccionar un usuario.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Buscar producto
                  const Text(
                    'Buscar producto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  BuscarProductoWidget(
                    idProductoController: _idProductoController,
                    cantidadController: _cantidadController,
                    productosController: _productosController,
                    isLoading: _isLoading,
                    selectedProducto: _selectedProducto,
                    onProductoSeleccionado: (producto) {
                      setState(() {
                        _selectedProducto = producto;
                      });
                    },
                    onAdvertencia: (message) {
                      showAdvertence(context, message);
                    },
                  ),
                  const SizedBox(height: 20),

                  //Botón para agregar producto a la tabla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _agregarProducto,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        label: const Text(
                          'Agregar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //Tabla productos agregados
                  tablaProductosAgregados(_productosAgregados),
                  const SizedBox(height: 30),

                  //Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //PDF e imprimir
                      ElevatedButton(
                        onPressed: () async {
                          bool datosCompletos =
                              await validarCamposAntesDeImprimir(
                            context: context,
                            productosAgregados: _productosAgregados,
                            referenciaController: _referenciaController,
                            selectedProveedor: _selectedProveedor,
                            selectedEntidad: _selectedEntidad,
                            selectedJunta: _selectedJunta,
                            selectedUser: _selectedUser,
                          );

                          if (!datosCompletos) {
                            return;
                          }                          

                          await generateAndSavePdf(
                            context: context,
                            movimiento: 'Entrada',
                            fecha: _fecha,
                            referencia: _referenciaController.text,
                            proveedor: _selectedProveedor?.proveedor_Name ??
                                'Sin Proveedor',
                            entidad: _selectedEntidad?.entidad_Nombre ??
                                'Sin Entidad',
                            junta: _selectedJunta?.junta_Name ?? 'Sin Junta',
                            usuario: _selectedUser?.user_Name ?? 'Sin Usuario',
                            productos: _productosAgregados,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Imprimir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 60),

                      //Guardar entrada
                      ElevatedButton(
                        onPressed: _guardarEntrada,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Guardar Entrada',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
