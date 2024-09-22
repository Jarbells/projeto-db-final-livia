-- Deletar todas as tabelas.
DROP TABLE IF EXISTS Agendamento;
DROP TABLE IF EXISTS Responsabilidade;
DROP TABLE IF EXISTS Medico_Servico;
DROP TABLE IF EXISTS Alergia;
DROP TABLE IF EXISTS Horario_Atendimento_Medico;
DROP TABLE IF EXISTS Horario_Atendimento_Secretario;
DROP TABLE IF EXISTS Email;
DROP TABLE IF EXISTS Telefone;
DROP TABLE IF EXISTS Endereco;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Medico;
DROP TABLE IF EXISTS Secretario;
DROP TABLE IF EXISTS Pessoa;
DROP TABLE IF EXISTS Servico;
DROP TABLE IF EXISTS Dia_Semana;

-- Utilizando o CASCADE para eliminar automaticamente todas as dependências relacionadas as tabelas.
DROP TABLE IF EXISTS Agendamento CASCADE;
DROP TABLE IF EXISTS Responsabilidade CASCADE;
DROP TABLE IF EXISTS Medico_Servico CASCADE;
DROP TABLE IF EXISTS Alergia CASCADE;
DROP TABLE IF EXISTS Horario_Atendimento_Medico CASCADE;
DROP TABLE IF EXISTS Horario_Atendimento_Secretario CASCADE;
DROP TABLE IF EXISTS Email CASCADE;
DROP TABLE IF EXISTS Telefone CASCADE;
DROP TABLE IF EXISTS Endereco CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS Medico CASCADE;
DROP TABLE IF EXISTS Secretario CASCADE;
DROP TABLE IF EXISTS Pessoa CASCADE;
DROP TABLE IF EXISTS Servico CASCADE;
DROP TABLE IF EXISTS Dia_Semana CASCADE;




CREATE SCHEMA sistema;
SET search_path TO sistema;

-- Tabela pessoa sem os vetores
CREATE TABLE Pessoa (
    ID_Pessoa SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    CPF CHAR(11) NOT NULL UNIQUE,
    CHECK (CPF ~ '^\d{11}$') -- CPF deve ser composto por 11 dígitos numéricos
);

-- Tabela email
CREATE TABLE Email (
    ID_Email SERIAL PRIMARY KEY,
    Email VARCHAR(255) NOT NULL,
    ID_Pessoa INT NOT NULL,
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE,
    CHECK (Email ~ '^[^\s@]+@[^\s@]+\.[^\s@]+$') -- Verificação simples de formato de email
);

-- Tabela telefone
CREATE TABLE Telefone (
    ID_Telefone SERIAL PRIMARY KEY,
    Telefone VARCHAR(20) NOT NULL,
    ID_Pessoa INT NOT NULL,
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE,
    CHECK (Telefone ~ '^\+?\d{8,15}$') -- Verifica se o telefone é composto por 8 a 15 dígitos, opcionalmente começando com '+'
);

-- Tabela endereco
CREATE TABLE Endereco (
    ID_Endereco SERIAL PRIMARY KEY,
    Rua VARCHAR(100) NOT NULL,
    Numero VARCHAR(10),
    Bairro VARCHAR(50),
    Cidade VARCHAR(50),
    Estado CHAR(2),
    ID_Pessoa INT NOT NULL,
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE
);

-- Tabela secretario herdando de pessoa
CREATE TABLE Secretario (
    ID_Secretario SERIAL PRIMARY KEY,
    ID_Pessoa INT NOT NULL UNIQUE,
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE
);

-- Tabela medico herdando de pessoa
CREATE TABLE Medico (
    ID_Medico SERIAL PRIMARY KEY,
    ID_Pessoa INT NOT NULL UNIQUE,
    CRM VARCHAR(20) NOT NULL UNIQUE,
    Especializacao VARCHAR(100) NOT NULL,
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE
);

-- Tabela cliente herdando de pessoa
CREATE TABLE Cliente (
    ID_Cliente SERIAL PRIMARY KEY,
    ID_Pessoa INT NOT NULL UNIQUE,
    Convenio VARCHAR(100),
    FOREIGN KEY (ID_Pessoa) REFERENCES Pessoa(ID_Pessoa) ON DELETE CASCADE
);

-- Tabela alergia relacionada com cliente
CREATE TABLE Alergia (
    ID_Alergia SERIAL PRIMARY KEY,
    Descricao TEXT NOT NULL,
    ID_Cliente INT NOT NULL,
    FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente) ON DELETE CASCADE
);

-- Tabela dia_semana
CREATE TABLE Dia_Semana (
    ID_Dia_Semana SERIAL PRIMARY KEY,
    Nome_Dia VARCHAR(20) NOT NULL UNIQUE
);

-- Populando a tabela dia_semana
INSERT INTO Dia_Semana (Nome_Dia) VALUES
('Segunda-feira'),
('Terça-feira'),
('Quarta-feira'),
('Quinta-feira'),
('Sexta-feira'),
('Sábado'),
('Domingo');

-- Tabela horario_atendimento_secretario
CREATE TABLE Horario_Atendimento_Secretario (
    ID_Horario_Secretario SERIAL PRIMARY KEY,
    ID_Dia_Semana INT NOT NULL,
    Hora_Inicio_Manha TIME,
    Hora_Fim_Manha TIME,
    Hora_Inicio_Tarde TIME,
    Hora_Fim_Tarde TIME,
    Hora_Inicio_Noite TIME,
    Hora_Fim_Noite TIME,
    ID_Secretario INT NOT NULL,
    FOREIGN KEY (ID_Dia_Semana) REFERENCES Dia_Semana(ID_Dia_Semana),
    FOREIGN KEY (ID_Secretario) REFERENCES Secretario(ID_Secretario) ON DELETE CASCADE,
    CHECK (Hora_Inicio_Manha IS NULL OR Hora_Fim_Manha IS NULL OR Hora_Inicio_Manha < Hora_Fim_Manha),
    CHECK (Hora_Inicio_Tarde IS NULL OR Hora_Fim_Tarde IS NULL OR Hora_Inicio_Tarde < Hora_Fim_Tarde),
    CHECK (Hora_Inicio_Noite IS NULL OR Hora_Fim_Noite IS NULL OR Hora_Inicio_Noite < Hora_Fim_Noite)
);

-- Tabela horario_atendimento_medico
CREATE TABLE Horario_Atendimento_Medico (
    ID_Horario SERIAL PRIMARY KEY,
    ID_Dia_Semana INT NOT NULL,
    Hora_Inicio_Manha TIME,
    Hora_Fim_Manha TIME,
    Hora_Inicio_Tarde TIME,
    Hora_Fim_Tarde TIME,
    Hora_Inicio_Noite TIME,
    Hora_Fim_Noite TIME,
    ID_Medico INT NOT NULL,
    FOREIGN KEY (ID_Dia_Semana) REFERENCES Dia_Semana(ID_Dia_Semana),
    FOREIGN KEY (ID_Medico) REFERENCES Medico(ID_Medico) ON DELETE CASCADE,
    CHECK (Hora_Inicio_Manha IS NULL OR Hora_Fim_Manha IS NULL OR Hora_Inicio_Manha < Hora_Fim_Manha),
    CHECK (Hora_Inicio_Tarde IS NULL OR Hora_Fim_Tarde IS NULL OR Hora_Inicio_Tarde < Hora_Fim_Tarde),
    CHECK (Hora_Inicio_Noite IS NULL OR Hora_Fim_Noite IS NULL OR Hora_Inicio_Noite < Hora_Fim_Noite)
);

-- Tabela servico
CREATE TABLE Servico (
    ID_Servico SERIAL PRIMARY KEY,
    Descricao TEXT NOT NULL,
    Valor DECIMAL(10, 2) NOT NULL CHECK (Valor >= 0)
);

-- Tabela medico_servico (relacionamento muitos-para-muitos)
CREATE TABLE Medico_Servico (
    ID_Medico INT NOT NULL,
    ID_Servico INT NOT NULL,
    PRIMARY KEY (ID_Medico, ID_Servico),
    FOREIGN KEY (ID_Medico) REFERENCES Medico(ID_Medico) ON DELETE CASCADE,
    FOREIGN KEY (ID_Servico) REFERENCES Servico(ID_Servico) ON DELETE CASCADE
);

-- Tabela agendamento
CREATE TABLE Agendamento (
    ID_Agendamento SERIAL PRIMARY KEY,
    Data DATE NOT NULL,
    Hora TIME NOT NULL,
    Status VARCHAR(50) NOT NULL,
    Valor DECIMAL(10, 2) CHECK (Valor >= 0),
    Observacao TEXT,
    ID_Cliente INT NOT NULL,
    ID_Secretario INT NOT NULL,
    ID_Medico INT NOT NULL,
    FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente) ON DELETE CASCADE,
    FOREIGN KEY (ID_Secretario) REFERENCES Secretario(ID_Secretario) ON DELETE CASCADE,
    FOREIGN KEY (ID_Medico) REFERENCES Medico(ID_Medico) ON DELETE CASCADE
);

-- Tabela responsabilidade
CREATE TABLE Responsabilidade (
    ID_Responsabilidade SERIAL PRIMARY KEY,
    Descricao TEXT NOT NULL,
    ID_Secretario INT NOT NULL,
    FOREIGN KEY (ID_Secretario) REFERENCES Secretario(ID_Secretario) ON DELETE CASCADE
);

-- Povoamento do banco
-- Inserindo em pessoa
INSERT INTO Pessoa (Nome, CPF)
VALUES ('Dr. João da Silva', '12345678901') -- Nome e CPF do médico.
RETURNING ID_Pessoa;

-- Inserindo em medico
INSERT INTO Medico (ID_Pessoa, CRM, Especializacao)
VALUES (1, '123456-SP', 'Cardiologista');

-- Inserindo em email
INSERT INTO Email (Email, ID_Pessoa)
VALUES ('joao.silva@hospital.com', 1);

-- Inserindo em telefone
INSERT INTO Telefone (Telefone, ID_Pessoa)
VALUES ('+5511999999999', 1);

-- Inserindo horario_atendimento_medico
-- Segunda-feira
INSERT INTO Horario_Atendimento_Medico (ID_Dia_Semana, Hora_Inicio_Manha, Hora_Fim_Manha, Hora_Inicio_Tarde, Hora_Fim_Tarde, ID_Medico)
VALUES (1, '08:00', '12:00', '13:00', '17:00', 1);

-- Quarta-feira
INSERT INTO Horario_Atendimento_Medico (ID_Dia_Semana, Hora_Inicio_Manha, Hora_Fim_Manha, Hora_Inicio_Tarde, Hora_Fim_Tarde, ID_Medico)
VALUES (3, '08:00', '12:00', '13:00', '17:00', 1);

-- Sexta-feira
INSERT INTO Horario_Atendimento_Medico (ID_Dia_Semana, Hora_Inicio_Manha, Hora_Fim_Manha, Hora_Inicio_Tarde, Hora_Fim_Tarde, ID_Medico)
VALUES (5, '08:00', '12:00', '13:00', '17:00', 1);

-- Inserindo na tabela servico
INSERT INTO Servico (Descricao, Valor)
VALUES ('Consulta Cardiológica', 300.00)
RETURNING ID_Servico;

-- Inserindo na tabela medico_servico
INSERT INTO Medico_Servico (ID_Medico, ID_Servico)
VALUES (1, 1);

-- Inserindo na tabela endereco
INSERT INTO Endereco (Rua, Numero, Bairro, Cidade, Estado, ID_Pessoa)
VALUES ('Rua das Pedrinhas', '123', 'Centro', 'Quixadá', 'CE', 1);





-- Consultar tudo sobre os médicos
SELECT 
    p.ID_Pessoa, 
    p.Nome, 
    p.CPF, 
    e.Email, 
    t.Telefone, 
    en.Rua, en.Numero, en.Bairro, en.Cidade, en.Estado, 
    m.CRM, 
    m.Especializacao, 
    hs.Nome_Dia AS Dia_Atendimento, 
    h.Hora_Inicio_Manha, h.Hora_Fim_Manha, h.Hora_Inicio_Tarde, h.Hora_Fim_Tarde, 
    s.Descricao AS Servico, 
    s.Valor
FROM 
    Pessoa p
JOIN 
    Medico m ON p.ID_Pessoa = m.ID_Pessoa
LEFT JOIN 
    Email e ON p.ID_Pessoa = e.ID_Pessoa
LEFT JOIN 
    Telefone t ON p.ID_Pessoa = t.ID_Pessoa
LEFT JOIN 
    Endereco en ON p.ID_Pessoa = en.ID_Pessoa
LEFT JOIN 
    Horario_Atendimento_Medico h ON m.ID_Medico = h.ID_Medico
LEFT JOIN 
    Dia_Semana hs ON h.ID_Dia_Semana = hs.ID_Dia_Semana
LEFT JOIN 
    Medico_Servico ms ON m.ID_Medico = ms.ID_Medico
LEFT JOIN 
    Servico s ON ms.ID_Servico = s.ID_Servico
WHERE 
    p.ID_Pessoa = 1; -- Substitua 1 pelo ID_Pessoa do médico que deseja consultar

