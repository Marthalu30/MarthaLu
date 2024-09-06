// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz estándar de ERC20
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Contrato para el token GRCCoin, utilizado en una pizzería para recompensar a los clientes
// que compran una pizza adicional para donación
contract GRCCPizzaT is IERC20 {
    // Información básica del token
    string public constant name = "GRCC ColorPizza";
    string public constant symbol = "GRCC";
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 100000 * 10 ** uint256(decimals); // 100,000 tokens

    // Dirección del administrador (dueño del contrato)
    address public admin;

    // Precio del token en Ether
    uint public tokenPrice = 0.001 ether;

    // Precio de una pizza en Ether
    uint public pizzaPrice = 0.00001 ether;

    // Estado de pausa del contrato
    bool public paused = false;

    // Mapeo para almacenar los balances de los usuarios
    mapping(address => uint256) private _balances;

    // Mapeo para las asignaciones de gasto permitidas (allowances)
    mapping(address => mapping(address => uint256)) private _allowances;

    // Evento para notificar la compra de una pizza
    event PizzaBought(address indexed buyer, uint256 etherSpent, uint256 tokensReceived);

    // Constructor que asigna todo el suministro inicial al administrador
    constructor() {
        admin = msg.sender;
        _assignInitialSupply(admin); // Asignar todos los tokens al creador
    }

    // Modificador para funciones que solo pueden ser ejecutadas por el admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Solo el admin puede ejecutar esta funcion");
        _;
    }

    // Modificador para permitir solo cuando el contrato no está pausado
    modifier whenNotPaused() {
        require(!paused, "El contrato esta pausado");
        _;
    }

    // Devuelve el suministro total de tokens en existencia
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Devuelve el balance de una cuenta específica
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // Transfiere tokens a un destinatario
    function transfer(address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(_balances[msg.sender] >= amount, "Saldo insuficiente");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Devuelve la cantidad permitida para que un tercero gaste en nombre del propietario
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Aprueba a un tercero para gastar tokens en nombre del propietario
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Transfiere tokens de un remitente a un destinatario utilizando el sistema de allowance
    function transferFrom(address sender, address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(_balances[sender] >= amount, "Saldo insuficiente");
        require(_allowances[sender][msg.sender] >= amount, "No permitido");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Función que permite a los clientes comprar una pizza y recibir tokens GRCCoin a cambio
    // Se verifica que el comprador envíe suficiente Ether para la compra
    function buyPizza() public payable whenNotPaused {
        require(msg.value >= pizzaPrice, "Debes enviar suficiente Ether para comprar una pizza");

        // Calcular la cantidad de tokens que el comprador recibirá basado en el Ether enviado
        uint256 tokensToReceive = (msg.value * 1 ether) / tokenPrice;
        require(_balances[admin] >= tokensToReceive, "No hay suficientes tokens disponibles");

        // Transferir los tokens del balance del admin al comprador
        _balances[admin] -= tokensToReceive;
        _balances[msg.sender] += tokensToReceive;

        // Emitir eventos para notificar la transferencia y la compra de la pizza
        emit Transfer(admin, msg.sender, tokensToReceive);
        emit PizzaBought(msg.sender, msg.value, tokensToReceive);
    }

    // Función para que el admin pueda retirar los fondos acumulados en el contrato
    function withdrawFunds() public onlyAdmin {
        payable(admin).transfer(address(this).balance);
    }

    // Función para que el admin establezca un nuevo precio para los tokens
    function setTokenPrice(uint newPrice) public onlyAdmin {
        tokenPrice = newPrice;
    }

    // Función para que el admin establezca un nuevo precio para la pizza
    function setPizzaPrice(uint newPrice) public onlyAdmin {
        pizzaPrice = newPrice;
    }

    // Función que permite al admin crear (mint) nuevos tokens
    function mint(uint256 amount) public onlyAdmin {
        _totalSupply += amount;
        _balances[admin] += amount;
        emit Transfer(address(0), admin, amount);
    }

    // Función que permite al admin quemar (burn) tokens para reducir el suministro total
    function burn(uint256 amount) public onlyAdmin {
        require(_balances[admin] >= amount, "Saldo insuficiente para quemar");
        _totalSupply -= amount;
        _balances[admin] -= amount;
        emit Transfer(admin, address(0), amount);
    }

    // Función para pausar el contrato, deshabilitando transferencias
    function pause() public onlyAdmin {
        paused = true;
    }

    // Función para reanudar las operaciones del contrato después de una pausa
    function unpause() public onlyAdmin {
        paused = false;
    }

    // Función privada para asignar el suministro inicial de tokens a una dirección específica (admin)
    function _assignInitialSupply(address initialWallet) private {
        _balances[initialWallet] = _totalSupply;
        emit Transfer(address(0), initialWallet, _totalSupply);
    }
}
