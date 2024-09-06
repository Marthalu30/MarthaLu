// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// PROPÓSITO: CREAR UN CONTRATO PARA UN CASO DE TRAZABILIDAD DE PRODUCTOS
contract Trazabilidad {

    struct Estado {
        string ubicacion;
        uint marcaTiempo;
    }

    struct Producto {
        string nombre;
        string lote; // Nuevo campo para el lote del producto
        Estado[] historialEstados;
    }

    mapping (uint => Producto) public productos;
    uint public contadorProductos;

    // FUNCIONES

    // Función registrar producto
    function registrarProducto(string memory _nombre, string memory _lote) public {
        contadorProductos++;
        productos[contadorProductos].nombre = _nombre;
        productos[contadorProductos].lote = _lote; // Asignar el lote al producto
    }

    // Función actualizar estado del producto
    function actualizarEstado(uint _idProducto, string memory _ubicacion) public  {
        require(_idProducto > 0 && _idProducto <= contadorProductos, "El producto no existe");
        productos[_idProducto].historialEstados.push(Estado({
            ubicacion: _ubicacion,
            marcaTiempo:block.timestamp
        }));
    }

    // Funcion obtener historial del producto
    function obtenerHistorial(uint _idProducto) public view returns(Estado[] memory) {
        require(_idProducto > 0 && _idProducto <= contadorProductos, "El producto no existe");
        return productos[_idProducto].historialEstados;
    }

    // Funcion obtener lista de productos
    function obtenerListaProductos() public view returns(string[] memory) {
        string[] memory listaProductos = new string[](contadorProductos);

        for (uint i = 1; i <= contadorProductos; i++) {
            listaProductos[i - 1] = productos[i].nombre;
        }

        return listaProductos;
    }

    // --- NUEVAS FUNCIONES ---

    // Función para agregar un lote a un producto existente
    function agregarLote(uint _idProducto, string memory _lote) public {
        require(_idProducto > 0 && _idProducto <= contadorProductos, "El producto no existe");
        productos[_idProducto].lote = _lote;
    }

    // Función para verificar la originalidad del producto
    // En un escenario real, se compararía el historial con una base de datos de confianza
    function verificarOriginalidad(uint _idProducto) public view returns(bool) {
        require(_idProducto > 0 && _idProducto <= contadorProductos, "El producto no existe");
        // Lógica de verificación simple: si el producto tiene al menos un estado en su historial,
        // se considera que ha sido rastreado y, por lo tanto, "original"
        return productos[_idProducto].historialEstados.length > 0; 
    }
}