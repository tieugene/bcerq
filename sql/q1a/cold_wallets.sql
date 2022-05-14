-- main table
CREATE TABLE IF NOT EXISTS t_cold (
	a_id INT NOT NULL,
	brand VARCHAR(10) NOT NULL
);
ALTER TABLE t_cold ADD CONSTRAINT cold_pkey PRIMARY KEY (a_id);
INSERT INTO t_cold (a_id, brand) VALUES
    (442172263, 'Binance'),
    (289151204, 'Binance'),
    (450630223, 'Binance'),
    (861816682, 'Binance'),
    (694005509, 'Binance'),
    (546660497, 'Bitfinex'),
    (447093667, 'Bitfinex'),
    (133378122, 'OKEX'),
    (91221545, 'OKEX'),
    (785700958, 'OKEX'),
    (808120553, 'OKEX'),
    (471332705, 'OKEX'),
    (633317183, 'OKEX'),
    (618652850, 'OKEX'),
    (797068644, 'OKEX'),
    (491368479, 'OKEX'),
    (754003463, 'OKEX'),
    (661255959, 'OKEX'),
    (786442204, 'OKEX'),
    (773530446, 'OKEX'),
    (738370591, 'OKEX'),
    (461882659, 'Bitrex'),
    (562670865, 'CoinCheck'),
    (462456876, 'Poloniex'),
    (282228113, 'BITMEX'),
    (426931094, 'Huobi'),
    (762754371, 'Huobi'),
    (706371601, 'Huobi'),
    (413155082, 'Huobi'),
    (460602947, 'Huobi'),
    (565266587, 'Huobi'),
    (494253450, 'Huobi'),
    (549109743, 'Huobi'),
    (861816603, 'Huobi'),
    (402680858, 'Coinbase'),
    (444786126, 'Coinbase'),
    (758450767, 'Kraken'),
    (439553182, 'Kraken'),
    (387402034, 'Kraken'),
    (841964978, 'Kraken'),
    (602761, 'P2Pool');
-- check
-- 1. all txo
SELECT
    t_cold.a_id AS a_id,
    addr.name,
    COUNT(*)
FROM t_cold
JOIN vout ON t_cold.a_id = vout.a_id
JOIN addr ON t_cold.a_id = addr.id
GROUP BY t_cold.a_id, addr.name
ORDER BY t_cold.a_id;
-- 2.