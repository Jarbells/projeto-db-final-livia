-- Criar esquema e setar para sistema
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
INSERT INTO Dia_Semana (ID_Dia_Semana, Nome_Dia) VALUES
(1, 'Domingo'),
(2, 'Segunda-feira'),
(3, 'Terça-feira'),
(4, 'Quarta-feira'),
(5, 'Quinta-feira'),
(6, 'Sexta-feira'),
(7, 'Sábado');

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