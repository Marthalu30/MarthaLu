// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlmacenarTextos {
    string private textoAlmacenado;
    address public propietario;

    constructor () {
        propietario = msg.sender;
    }

    // Función para almacenar texto (cualquier usuario)
    function almacenarTexto (string memory nuevoTexto) public {
        textoAlmacenado = nuevoTexto;
    }

    // Función para consultar el texto almacenado (cualquier usuario)
    function consultarTexto() public view returns (string memory) {
        return textoAlmacenado;
    }

    // Función para actualizar el texto (solo propietario)
    function actualizarTexto(string memory nuevoTexto) public {
        // Requerir que solo el propietario pueda actualizar el texto
        require(msg.sender == propietario, "Solo el propietario puede actualizar el texto");
        textoAlmacenado = nuevoTexto;
    }
}