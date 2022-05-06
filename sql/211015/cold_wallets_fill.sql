-- tmp table
DROP TABLE IF EXISTS tmp_cold;
CREATE TEMP TABLE tmp_cold (
    brand VARCHAR(10) NOT NULL,
    aname JSONB NOT NULL
);
ALTER TABLE tmp_cold ADD CONSTRAINT tmp_cold_pkey PRIMARY KEY (aname);
INSERT INTO tmp_cold (brand, aname) VALUES
    ('Binance', to_jsonb('34xp4vRoCGJym3xR7yCVPFHoCNxv4Twseo'::TEXT)),
    ('Binance', to_jsonb('1NDyJtNTjmwk5xPNhjgAMu4HDHigtobu1s'::TEXT)),
    ('Binance', to_jsonb('3M219KR5vEneNb47ewrPfWyb5jQ2DjxRP6'::TEXT)),
    ('Binance', to_jsonb('bc1ql42rmpvvq488tkqxvg8wmaa7j3jsrkxgnm8cy6'::TEXT)),
    ('Binance', to_jsonb('bc1qqxf98drymkq5awwtt685l6463tmtumlrvqfxv2'::TEXT)),
    ('Bitfinex', to_jsonb('bc1qgdjqv0av3q56jvd82tkdjpy7gdp9ut8tlqmgrpmv24sq90ecnvqqjwvw97'::TEXT)),
    ('Bitfinex', to_jsonb('3JZq4atUahhuA9rLhXLMhhTo133J9rF97j'::TEXT)),
    ('OKEX', to_jsonb('38UmuUqPCrFmQo4khkomQwZ4VbY2nZMJ67'::TEXT)),
    ('OKEX', to_jsonb(' 3Kzh9qAqVWQhEsfQz7zEQL1EuSx5tyNLNS'::TEXT)),
    ('OKEX', to_jsonb('3FupZp77ySr7jwoLYEJ9mwzJpvoNBXsBnE'::TEXT)),
    ('OKEX', to_jsonb('3HSMPBUuAPQf6CU5B3qa6fALrrZXswHaF1'::TEXT)),
    ('OKEX', to_jsonb('3DVJfEsDTPkGDvqPCLC41X85L1B1DQWDyh'::TEXT)),
    ('OKEX', to_jsonb('3ETUmNhL2JuCFFVNSpk8Bqx2eorxyP9FVh'::TEXT)),
    ('OKEX', to_jsonb('3DwVjwVeJa9Z5Pu15WHNfKcDxY5tFUGfdx'::TEXT)),
    ('OKEX', to_jsonb('36NkTqCAApfRJBKicQaqrdKs29g6hyE4LS'::TEXT)),
    ('OKEX', to_jsonb('bc1quq29mutxkgxmjfdr7ayj3zd9ad0ld5mrhh89l2'::TEXT)),
    ('OKEX', to_jsonb('3ANziRvoBdNGkmGopgyhvzPuBvcL8sRL7S'::TEXT)),
    ('OKEX', to_jsonb('3FQ1j5SRRTBihpw97A5mWcaE8jn9u9YGoc'::TEXT)),
    ('OKEX', to_jsonb('3JmxvMqm35aLDUHXDbESy6rQz4M8MBQD32'::TEXT)),
    ('OKEX', to_jsonb('3BT3JFq8MGHK4YzsXfFWmEZ3bupJ1Cmgp8'::TEXT)),
    ('OKEX', to_jsonb('bc1qsrnf7ad2t2x0hvf9qxtjufftshx5jjqqdaame8'::TEXT)),
    ('Bitrex', to_jsonb('385cR5DM96n1HvBDMzLHPYcw89fZAXULJP'::TEXT)),
    ('CoinCheck', to_jsonb('3LCGsSmfr24demGvriN4e3ft8wEcDuHFqh'::TEXT)),
    ('Poloniex', to_jsonb('3H5JTt42K7RmZtromfTSefcMEFMMe18pMD'::TEXT)),
    ('BITMEX', to_jsonb('3BMEXqGpG4FxBA1KWhRFufXfSTRgzfDBhJ'::TEXT)),
    ('Huobi', to_jsonb('16AhJPQwo5NgpcHbyQA2f7BqWVjePN6nAq'::TEXT)),
    ('Huobi', to_jsonb('1Au6T3MTYMFYgXXfqQrjGKPd27R75Aztfu'::TEXT)),
    ('Huobi', to_jsonb('1BKN5obhkdoequshHnn96zZvFi3wCEdfiC'::TEXT)),
    ('Huobi', to_jsonb('1EgRfQtiDKy74mFxJBFxpKiahkvh9FrnRh'::TEXT)),
    ('Huobi', to_jsonb('1BZGtMiwxncH6pSziuxxW6FpcZPRV3CYnK'::TEXT)),
    ('Huobi', to_jsonb('1AwkRd2E8DmYtBHWRhrqnReC3eyVhhHRGF'::TEXT)),
    ('Huobi', to_jsonb('13sAgarPMUPuNkJdRCNr8FiqZrP7RiYwNA'::TEXT)),
    ('Huobi', to_jsonb('1L1xSXttdsBAPVjVfyoyCg3RZbdHinT5G5'::TEXT)),
    ('Huobi', to_jsonb('1ArUgVX6xZxDgPxnHig5sAxdhoybv3y3Lc'::TEXT)),
    ('Coinbase', to_jsonb('1FzWLkAahHooV3kzTgyx6qsswXJ6sCXkSR'::TEXT)),
    ('Coinbase', to_jsonb('1CAhFPhKkTLWLinCcXNDHNjPDwikwatktx'::TEXT)),
    ('Kraken', to_jsonb('3KTQYXvjteNoMECi62JYuqXobYQpcHjoVs'::TEXT)),
    ('Kraken', to_jsonb('36WJXbAqeNEiKqPZ4xKoG3KBXafrhabuWp'::TEXT)),
    ('Kraken', to_jsonb('37fvTdvVcidi6p6We5BDs8Zr257K2N8227'::TEXT)),
    ('Kraken', to_jsonb('35G8yS3fJjPTNZdcQCP6TdtUFPG7nD2SfG'::TEXT)),
    ('P2Pool', to_jsonb('1J1F3U7gHrCjsEsRimDJ3oYBiV24wA8FuV'::TEXT));
--
SELECT * FROM tmp_cold INNER JOIN addr ON tmp_cold.aname = addr.name;
-- TRUNCATE TABLE cold
-- insert addr.id, tmp_cold.brand into cold

