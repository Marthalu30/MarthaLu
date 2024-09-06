// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz para el contrato GestorUsuarios
interface GestorUsuarios {
    function estaUsuarioRegistrado(address _usuario) external view returns (bool);
}

contract RegistroDatos {

    // Dirección del contrato GestorUsuarios
    GestorUsuarios private gestorUsuarios;

    // Mapping para almacenar los registros de cada usuario
    mapping(address => string[]) private registrosUsuario;

    // Constructor que recibe la dirección del contrato GestorUsuarios
    constructor(address _direccionGestorUsuarios) {
        gestorUsuarios = GestorUsuarios(_direccionGestorUsuarios);
    }

    // FUNCION: Para registrar los datos
    function registrarDato(string memory _dato) public {
        // Requiere que el usuario esté registrado en el GestorUsuarios
        require(gestorUsuarios.estaUsuarioRegistrado(msg.sender), "Debes estar registrado para registrar datos");

        // Agrega el dato al array de registros del usuario
        registrosUsuario[msg.sender].push(_dato);
    }

    // FUNCION: Para obtener los registros 
    function obtenerRegistros() public view returns(string[] memory) {
        // Devuelve el array de registros del usuario
        return registrosUsuario[msg.sender];
    }

    // Nueva función 1: Permite a los usuarios autorizados modificar un dato existente.
    function modificarDato(uint _indice, string memory _nuevoDato) public {
        // Requiere que el usuario esté registrado en el GestorUsuarios
        require(gestorUsuarios.estaUsuarioRegistrado(msg.sender), "Debes estar registrado para modificar datos");
        // Requiere que el índice esté dentro del rango del array
        require(_indice < registrosUsuario[msg.sender].length, "Indice fuera de rango");

        // Modifica el dato en el índice especificado
        registrosUsuario[msg.sender][_indice] = _nuevoDato;
    }

    // Nueva función 2: Permite a los usuarios autorizados eliminar un dato.
    function eliminarDato(uint _indice) public {
        // Requiere que el usuario esté registrado en el GestorUsuarios
        require(gestorUsuarios.estaUsuarioRegistrado(msg.sender), "Debes estar registrado para eliminar datos");
        // Requiere que el índice esté dentro del rango del array
        require(_indice < registrosUsuario[msg.sender].length, "Indice fuera de rango");

        // Desplaza el último elemento al índice a eliminar.
        registrosUsuario[msg.sender][_indice] = registrosUsuario[msg.sender][registrosUsuario[msg.sender].length - 1];

        // Reducir la longitud del array para eliminar el último elemento duplicado.
        registrosUsuario[msg.sender].pop();
    } 
}