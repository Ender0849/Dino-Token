pragma solidity ^0.8.0;
 
interface IERC20 {

   //Возвращает количество существующих токенов.

   function totalSupply() external view returns (uint256);
 
   /*
    Возвращает количество токенов, принадлежащих кошельку.
    */
   function balanceOf(address account) external view returns (uint256);
 
   /*
    Перемещает токены "сумма` из учетной записи вызывающего абонента в "получатель". Возвращает логическое значение, указывающее, была ли операция выполнена успешно.
    Выдает событие {Transfer}
    */
   function transfer(address recipient, uint256 amount) external returns (bool);
 
   /*
    Возвращает оставшееся количество токенов, которые "транжире" будет
    разрешено потратить от имени "владельца" посредством {transfer From}.
    По умолчанию это значение равно нулю.

    Это значение изменяется при вызове {approve} или {transfer From}.
    */
   function allowance(address owner, address spender) external view returns (uint256);
 
   /*
    Устанавливает `сумму` как надбавку `транжире` за токены вызывающего абонента.

    Возвращает логическое значение, указывающее, была ли операция выполнена успешно.
 
   /*
    Перемещает токены "количество" от `отправителя` к `получателю`, используя
    механизм надбавок. затем "сумма` вычитается из счета вызывающего абонента.
    пособие.

    Возвращает логическое значение, указывающее, была ли операция выполнена успешно.

    Выдает событие {Transfer}.
    */
   function transferFrom(
       address sender,
       address recipient,
       uint256 amount
   ) external returns (bool);
 
   /*
    Генерируется, когда токены `value` перемещаются с одной учетной записи (`from`) на
    другой (`кому`).
    Обратите внимание, что "value` может быть равно нулю.
*/
   event Transfer(address indexed from, address indexed to, uint256 value);
 
   /**
    v Выдается, когда надбавка `spender` для 'owner` устанавливается
    вызов {approve}. `value` - это новая надбавка.
    */
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
   /**
    * @dev Returns the name of the token.
    */
   function name() external view returns (string memory);
 
   /**
    Returns the name of the token.
    */
   function symbol() external view returns (string memory);
 
   /**
    Возвращает десятичные знаки токена.
    */
   function decimals() external view returns (uint8);
}
abstract contract Context {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }
 
   function _msgData() internal view virtual returns (bytes calldata) {
       return msg.data;
   }
}
 
contract ERC20 is Context, IERC20, IERC20Metadata {
   mapping(address => uint256) private _balances;
 
   mapping(address => mapping(address => uint256)) private _allowances;
 
   uint256 private _totalSupply;
 
   string private _name;
   string private _symbol;
 
   /*
    Задает значения для {name} и {symbol}.
    */
   constructor(string memory name_, string memory symbol_) {
       _name = name_;
       _symbol = symbol_;
   }
 
   /**
    Возвращает имя токена.
    */
   function name() public view virtual override returns (string memory) {
       return _name;
   }
 
   /*
    Возвращает символ токена, обычно более короткую версию.
    */
   function symbol() public view virtual override returns (string memory) {
       return _symbol;
   }
 
   /*
    Возвращает количество десятичных знаков, использованных для получения его пользовательского представления.
    Например, если "десятичные дроби" равны "2", баланс токенов "505" должен
    отображаться пользователю в виде `5.05` (`505 / 10 ** 2`).
    *

    */
   function decimals() public view virtual override returns (uint8) {
       return 18;
   }
 
   function totalSupply() public view virtual override returns (uint256) {
       return _totalSupply;
   }
 
   /**
    См. {IERC20-balanceOf}.
    */
   function balanceOf(address account) public view virtual override returns (uint256) {
       return _balances[account];
   }
 
   /*
     См. {IERC20-transfer}.
    
    Требования:
    - `получатель` не может быть нулевым адресом.
    - у вызывающего абонента должен быть баланс не менее "суммы".
    */
   function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
       _transfer(_msgSender(), recipient, amount);
       return true;
   }
 
   /*
    См. {IERC20-allowance}.
    */
   function allowance(address owner, address spender) public view virtual override returns (uint256) {
       return _allowances[owner][spender];
   }
 
   /*
    См. {IERC20-approve}.
    
    ПРИМЕЧАНИЕ: Если "amount" является максимальной "uint256", пособие не обновляется на
    `transferFrom". Это семантически эквивалентно бесконечному одобрению.
    Требования:
    - `spender` не может быть нулевым адресом.
    */
   function approve(address spender, uint256 amount) public virtual returns (bool) {
       _approve(_msgSender(), spender, amount);
       return true;
   }
 
   /*
    Выдает событие {Утверждение}, указывающее на обновленную надбавку. Это не
    требуется в соответствии с EIP. Смотрите примечание в начале {ERC20}.

    ПРИМЕЧАНИЕ: Надбавка не обновляется, если текущая надбавка
    - это максимальное значение "uint256`.

    Требования:

    - `sender` и "recipient" не могут быть нулевыми адресами.
     - У "sender` должен быть баланс не менее "суммы`.
    - вызывающий абонент должен иметь допуск к токенам `sender` не менее
    `amount`.
    */
   function transferFrom(
       address sender,
       address recipient,
       uint256 amount
   ) public virtual override returns (bool) {
       uint256 currentAllowance = _allowances[sender][_msgSender()];
       if (currentAllowance != type(uint256).max) {
           require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
           unchecked {
               _approve(sender, _msgSender(), currentAllowance - amount);
           }
       }
 
       _transfer(sender, recipient, amount);
 
       return true;
   }
 
   /**
    Атомарно увеличивает пособие, предоставляемое "spender" вызывающим абонентом.

    */
   function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
       _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
       return true;
   }
 
   /*
    Автоматически уменьшает пособие, предоставляемое "spender" вызывающим абонентом.
    Выдает событие {Approval}, указывающее на обновленную надбавку.
    Требования:
    - `spender` не может быть нулевым адресом.
    - `spender" должна иметь допуск для вызывающего абонента не менее
    `subtractedValue`.
    */
   function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
       uint256 currentAllowance = _allowances[_msgSender()][spender];
       require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
       unchecked {
           _approve(_msgSender(), spender, currentAllowance - subtractedValue);
       }
 
       return true;
   }
 
   /**
    Перемещает `amount` токенов из "sender" в "recipient".

    Эта внутренняя функция эквивалентна {transfer} и может использоваться для
    например, внедрить автоматическую плату за токены, механизмы сокращения и т.д.

    Выдает событие {Transfer}.

    Требования:

    - `sender` не может быть нулевым адресом.
    - `recipient` не может быть нулевым адресом.
    - У "sender` должен быть баланс не менее "amount`.
    */
   function _transfer(
       address sender,
       address recipient,
       uint256 amount
   ) internal virtual {
       require(sender != address(0), "ERC20: transfer from the zero address");
       require(recipient != address(0), "ERC20: transfer to the zero address");
 
       _beforeTokenTransfer(sender, recipient, amount);
 
       uint256 senderBalance = _balances[sender];
       require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
       unchecked {
           _balances[sender] = senderBalance - amount;
       }
       _balances[recipient] += amount;
 
       emit Transfer(sender, recipient, amount);
 
       _afterTokenTransfer(sender, recipient, amount);
   }
 
   /*  
   Создает токены "amount` и присваивает их "account", увеличивая
    общее предложение.

    Выдает событие {Transfer} с `from`, установленным на нулевой адрес.

    Требования:

    - `account" не может быть нулевым адресом.
    */
   function _mint(address account, uint256 amount) internal virtual {
       require(account != address(0), "ERC20: mint to the zero address");
 
       _beforeTokenTransfer(address(0), account, amount);
 
       _totalSupply += amount;
       _balances[account] += amount;
       emit Transfer(address(0), account, amount);
 
       _afterTokenTransfer(address(0), account, amount);
   }
 
   /**
    Уничтожает токены "amount` со "account", уменьшая
    общее предложение.
    Выдает событие {Transfer} с `to`, установленным на нулевой адрес.

    Требования:
    - `account" не может быть нулевым адресом.
    - В "account` должно быть не менее токенов "amount`.
    */
   function _burn(address account, uint256 amount) internal virtual {
       require(account != address(0), "ERC20: burn from the zero address");
 
       _beforeTokenTransfer(account, address(0), amount);
 
       uint256 accountBalance = _balances[account];
       require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
       unchecked {
           _balances[account] = accountBalance - amount;
       }
       _totalSupply -= amount;
 
       emit Transfer(account, address(0), amount);
 
       _afterTokenTransfer(account, address(0), amount);
   }
 
   /**
    Устанавливает `amount` как надбавку `spender` за токены "owner".

    Эта внутренняя функция эквивалентна "approve` и может использоваться для
    например, установить автоматические надбавки для определенных подсистем и т.д.

    Выдает событие {Approval}.

    Требования:

    - `owner` не может быть нулевым адресом.
    - `spender` не может быть нулевым адресом.
    */
   function _approve(
       address owner,
       address spender,
       uint256 amount
   ) internal virtual {
       require(owner != address(0), "ERC20: approve from the zero address");
       require(spender != address(0), "ERC20: approve to the zero address");
 
       _allowances[owner][spender] = amount;
       emit Approval(owner, spender, amount);
   }
 
   /*
   Хук, который вызывается перед любой передачей токенов. Это включает в себя
    майнинг и сжигание.

    Условия вызова:

     - когда `from` и `to` оба ненулевые, `amount` токенов `from`
    будет переведен в раздел "to`.
    - когда `from` равно нулю, токены `amount` будут отчеканены для `to`.
    - когда `to" равно нулю, "amount" токенов "from` будет сожжено.
    - "from" и `to` никогда не равны нулю.

*/
   function _beforeTokenTransfer(
       address from,
       address to,
       uint256 amount
   ) internal virtual {}
 
   /*
    Хук, который вызывается перед любой передачей токенов. Это включает в себя
    майнинг и сжигание.

    Условия вызова:

     - когда `from` и `to` оба ненулевые, `amount` токенов `from`
    будет переведен в раздел "to`.
    - когда `from` равно нулю, токены `amount` будут отчеканены для `to`.
    - когда `to" равно нулю, "amount" токенов "from` будет сожжено.
    - "from" и `to` никогда не равны нулю.
*
  
    */
   function _afterTokenTransfer(
       address from,
       address to,
       uint256 amount
   ) internal virtual {}
}
 
contract Dino is ERC20 {
   constructor() ERC20("Dino Token", "DINO") {
       _mint(msg.sender, 2107 * (10 ** uint256(decimals())));
   }
}
