// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface AggregatorV3Interface {
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
}

contract PrecioEURUSD {
    AggregatorV3Interface internal precioFeed;
    
    constructor() public {
        precioFeed = AggregatorV3Interface(0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910); 
    }  

    // Las funciones obtenerPrecio y obtenerTimestamp deben estar DENTRO del contrato
    function obtenerPrecio() public view returns (int256) { 
        // Obtener la respuesta como uint256
        uint256 precioComoUint = uint256(precioFeed.latestAnswer());
        // Convertir a int256 y retornar
        return int256(precioComoUint); 
    }

    function obtenerTimestamp() public view returns (uint256) {
        uint256 miTimestamp = precioFeed.latestTimestamp();
        return miTimestamp;
    }
}