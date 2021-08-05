// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract contrato_prestacao {
    
    //iniciando as variáveis
    uint256 public preco;          //preço do contrato em ether
	uint8 public prazoTotal;       //prazo total do contrato em dias
	uint256 public tempoRestante;  //tempo restante para acabar o contrato    diasRestantes
	uint8 public qntVisitas;       //quantidade de visitas tecnicas

	//inicia a garantia paga como falso
	bool private garantiaPrestadorPaga = false;   
    bool private garantiaClientePaga = false;

    //função para mapear os endereços dos participantes e os saldos pagos
	mapping (address =>uint) saldos;
    
    //variável guardar os endereços dos participantes
    address public prestador;
    address public cliente;
	address public contrato;
	
	//variavel guardar  os endereços dos participantes para pagamento
	address payable payableCliente;
	address payable payablePrestador;
	address payable payableContrato;
	//---------------2------------------------------------------------// 
	enum Estado {Criado, Estabelecido, Fornecido, Encerrado, Cancelado}
	Estado private estado;
	
	constructor(uint256 _preco,
		uint8 _prazoTotal,
		uint8 _qntVisitas,
		address _prestador,
		address _cliente
		
		)public {
		preco = _preco * 1000000000000000000;
		prazoTotal = _prazoTotal;
	    qntVisitas = _qntVisitas;
	    prestador = _prestador;
		cliente = _cliente;
		
		estado = Estado.Criado;
		contrato = address(this);
		payableCliente = address( uint(cliente) );
		payablePrestador = address( uint(prestador) );
		payableContrato = address( uint(contrato) );
    }
    //-----------------3----------------------------------------------//
    modifier apenasPrestador{
		require(msg.sender == prestador, "Você não é o prestador deste contrato");
		_;
	}
    
    modifier apenasCliente{
		require(msg.sender == cliente, "Você não é o cliente deste contrato");
		_;
	}
	
	function abortar() private {
		require(estado == Estado.Cancelado);
		payableCliente.transfer(preco + preco/10);
	}
	
	function depositar() private {
		require(estado == Estado.Encerrado);
		payablePrestador.transfer(preco + preco/10);
	}
	//-------------------4--------------------------------------------//
    function garantiaCliente() public apenasCliente payable {
		require(msg.value == preco, "Preço errado");
		saldos[msg.sender]+= msg.value;
		garantiaClientePaga = true;

		if(garantiaPrestadorPaga == true){
			contratoEstabelecido();
		}
	}

	function garantiaPrestador() public apenasPrestador payable {
		require(msg.value == preco/10, "Preço errado ");
		saldos[msg.sender]+= msg.value;
		garantiaPrestadorPaga = true;
		
		if(garantiaClientePaga == true){
			contratoEstabelecido();
		}
	}
	
	
	function estornarGarantias() public payable {
		require(estado == Estado.Criado, "Estorno Invalido");
		if(garantiaPrestadorPaga == true){
			payablePrestador.transfer(preco/10);
			garantiaPrestadorPaga = false;
	    }
		if(garantiaClientePaga == true){
			payableCliente.transfer(preco);
			garantiaClientePaga = false;
		}
		estado = Estado.Cancelado;
	}
	
	function contratoEstabelecido() private {
		require(garantiaPrestadorPaga == true && garantiaClientePaga == true,"Garantias não feitas");
		estado = Estado.Estabelecido;
		tempoRestante = now + (prazoTotal * 1 days);
		}
	//--------------------5-------------------------------------------//
	function servicoPrestado() public apenasPrestador{
		require(estado == Estado.Estabelecido, "Serviço não válido");
		if(now <= tempoRestante){
			estado = Estado.Fornecido;
		} else {
			abortar();
		}
	}
		
	function servicoRecebido() public apenasCliente{
		require(estado == Estado.Fornecido, "Serviço ainda não prestado");
		if(now <= tempoRestante){
			estado = Estado.Encerrado;
			depositar();
		} else {
			estado = Estado.Cancelado;
		}
	}
    //---------------------6------------------------------------------//
	function numeroContrato() public view returns(address contratoAddr){
		return address(this);
	}

	function saldoDoContrato() public view returns(uint){
		return address(this).balance;
	}
    
    function diminirVisitaTecnica() public apenasPrestador returns (uint8){
        return qntVisitas--;
    }
    
	function diasRestantes() public view returns(uint){
		if(estado != Estado.Criado){
			return (tempoRestante - now)/ 60 / 60 / 24;
		} else {
			return 0;
		}
	}
   //------------------------7---------------------------------------// 
	function tarefasContrato() public pure returns(string memory tarefas){
		return ("As tarefas a serem feitas para que o contrato seja dado como encerrado são as seguites:" 
		"1 Formatação dos computadores;"
		"2 Instalação do sistema operacional;"
		"3 Limpeza dos computadores;"
		"4 atender as visitas técnicas."
		);
	}
		
	function EstadoContrato() public view returns (string memory estadoAtual ){
		if(estado == Estado.Criado){
			return ("Contrato Criado");
		}
		if(estado == Estado.Estabelecido){
			return ("Contrato Estabelecido");
		}
		if(estado == Estado.Fornecido){
			return ("Contrato Fornecido");
		}
		if(estado == Estado.Encerrado){
			return ("Contrato Encerrado");
		}
		if(estado == Estado.Cancelado){
			return ("Contrato Cancelado");
		}
	}
}



