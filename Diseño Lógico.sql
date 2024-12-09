CREATE TABLE "Reasegurador" (
  "reasegurador" text UNIQUE PRIMARY KEY,
  "nombre_programa" text
);

CREATE TABLE "Aseguradora" (
  "aseguradora_id" text UNIQUE PRIMARY KEY,
  "nombre_aseguradora" text,
  "reasegurador" text
);

CREATE TABLE "Poliza" (
  "poliza_endoso" text UNIQUE PRIMARY KEY,
  "asegurado" text,
  "vig_desde" date,
  "vig_hasta" date,
  "tipo_seguro" text,
  "suma_asegurada" numeric,
  "cotizacion_moneda" numeric,
  "aseguradora_id" text
);

CREATE TABLE "Prima" (
  "poliza_endoso" text,
  "prima_emitida" numeric,
  "comisiones" numeric,
  "porc_comis_fronting" numeric
);

COMMENT ON COLUMN "Reasegurador"."reasegurador" IS '''HD'' o ''AX'' - Nombre del reasegurador';

COMMENT ON COLUMN "Reasegurador"."nombre_programa" IS 'Nombre de casa matriz del asegurado a nivel global (''HH'', ''AA'', ''BB'')';

COMMENT ON COLUMN "Aseguradora"."aseguradora_id" IS 'Identificador único de la aseguradora';

COMMENT ON COLUMN "Aseguradora"."nombre_aseguradora" IS 'Nombre de la aseguradora';

COMMENT ON COLUMN "Aseguradora"."reasegurador" IS 'Reasegurador asociado a la aseguradora (''HD'', ''AX'')';

COMMENT ON COLUMN "Poliza"."poliza_endoso" IS 'Identificador único para cada póliza';

COMMENT ON COLUMN "Poliza"."asegurado" IS 'Nombre único del asegurado';

COMMENT ON COLUMN "Poliza"."vig_desde" IS '''YYYY-MM-DD'' - Fecha de inicio de la cobertura';

COMMENT ON COLUMN "Poliza"."vig_hasta" IS '''YYYY-MM-DD'' - Fecha de fin de la cobertura';

COMMENT ON COLUMN "Poliza"."tipo_seguro" IS '''Incendio'', ''Automóviles'', ''Responsabilidad Civil'', ''Seguro Técnico'', ''Transporte Mercaderías'', ''Acc. Personales''';

COMMENT ON COLUMN "Poliza"."suma_asegurada" IS '>= 0 - Monto total asegurado por la póliza';

COMMENT ON COLUMN "Poliza"."cotizacion_moneda" IS '''1'' = Pesos, otros valores para USD';

COMMENT ON COLUMN "Poliza"."aseguradora_id" IS 'Clave foránea que indica la aseguradora responsable de la póliza';

COMMENT ON COLUMN "Prima"."poliza_endoso" IS 'Clave foránea que conecta con la póliza';

COMMENT ON COLUMN "Prima"."prima_emitida" IS '>= 1 - Valor de la prima emitida';

COMMENT ON COLUMN "Prima"."comisiones" IS '>= 0 - Comisión del broker';

COMMENT ON COLUMN "Prima"."porc_comis_fronting" IS '0-100 - Porcentaje de comisión de la aseguradora';

ALTER TABLE "Aseguradora" ADD FOREIGN KEY ("reasegurador") REFERENCES "Reasegurador" ("reasegurador");

ALTER TABLE "Poliza" ADD FOREIGN KEY ("aseguradora_id") REFERENCES "Aseguradora" ("aseguradora_id");

ALTER TABLE "Prima" ADD FOREIGN KEY ("poliza_endoso") REFERENCES "Poliza" ("poliza_endoso");
