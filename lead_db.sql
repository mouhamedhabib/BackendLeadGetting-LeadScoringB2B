--
-- PostgreSQL database dump
--

\restrict KAIBQIpn4F6E6awZUnGTR7nQZeMvX8JIsK3xTurDmIbwCQVbrvcZtDghbvjUHJS

-- Dumped from database version 17.10 (Debian 17.10-1.pgdg13+1)
-- Dumped by pg_dump version 17.10 (Debian 17.10-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: leads_state_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.leads_state_enum AS ENUM (
    'RAW',
    'NORMALIZED',
    'ENRICHED',
    'SCORED',
    'FAILED'
);


ALTER TYPE public.leads_state_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: lead_analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lead_analysis (
    id integer NOT NULL,
    lead_id character varying NOT NULL,
    website_url character varying,
    has_website boolean,
    has_ssl boolean,
    has_facebook boolean,
    has_instagram boolean,
    seo_title character varying,
    seo_description character varying,
    mobile_friendly boolean,
    performance_score integer,
    analysis_status character varying,
    analyzed_at timestamp without time zone
);


ALTER TABLE public.lead_analysis OWNER TO postgres;

--
-- Name: lead_analysis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lead_analysis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_analysis_id_seq OWNER TO postgres;

--
-- Name: lead_analysis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lead_analysis_id_seq OWNED BY public.lead_analysis.id;


--
-- Name: lead_axis_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lead_axis_scores (
    id integer NOT NULL,
    lead_id character varying NOT NULL,
    analysis_id integer,
    axis character varying NOT NULL,
    score numeric,
    weight numeric,
    weighted_score numeric,
    is_available boolean DEFAULT true NOT NULL,
    score_type character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CHK_lead_axis_scores_axis" CHECK (((axis)::text = ANY ((ARRAY['GMB'::character varying, 'WEBSITE'::character varying, 'SEO'::character varying, 'SOCIAL'::character varying])::text[]))),
    CONSTRAINT "CHK_lead_axis_scores_score_type" CHECK (((score_type)::text = ANY ((ARRAY['digital_maturity'::character varying, 'opportunity'::character varying])::text[])))
);


ALTER TABLE public.lead_axis_scores OWNER TO postgres;

--
-- Name: lead_axis_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lead_axis_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_axis_scores_id_seq OWNER TO postgres;

--
-- Name: lead_axis_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lead_axis_scores_id_seq OWNED BY public.lead_axis_scores.id;


--
-- Name: lead_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lead_contacts (
    id integer NOT NULL,
    lead_id character varying NOT NULL,
    name character varying,
    email character varying,
    phone character varying,
    source character varying,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.lead_contacts OWNER TO postgres;

--
-- Name: lead_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lead_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_contacts_id_seq OWNER TO postgres;

--
-- Name: lead_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lead_contacts_id_seq OWNED BY public.lead_contacts.id;


--
-- Name: lead_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lead_scores (
    id integer NOT NULL,
    lead_id character varying NOT NULL,
    analysis_id integer,
    period_type character varying,
    digital_maturity numeric,
    opportunity numeric,
    analysis_cost numeric,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    score_date date NOT NULL
);


ALTER TABLE public.lead_scores OWNER TO postgres;

--
-- Name: lead_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lead_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_scores_id_seq OWNER TO postgres;

--
-- Name: lead_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lead_scores_id_seq OWNED BY public.lead_scores.id;


--
-- Name: leads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.leads (
    google_place_id character varying NOT NULL,
    name character varying,
    address character varying,
    phone character varying,
    website character varying,
    rating double precision,
    "userRatingsTotal" integer,
    lat double precision,
    lng double precision,
    "searchQuery" character varying NOT NULL,
    state public.leads_state_enum DEFAULT 'RAW'::public.leads_state_enum NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "lastUpdated" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.leads OWNER TO postgres;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: scraping_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scraping_jobs (
    id integer NOT NULL,
    lead_id character varying NOT NULL,
    job_type character varying(30) NOT NULL,
    status character varying(30) NOT NULL,
    source character varying(50),
    trigger character varying(50),
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    duration_ms integer,
    error_message text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.scraping_jobs OWNER TO postgres;

--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scraping_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraping_jobs_id_seq OWNER TO postgres;

--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scraping_jobs_id_seq OWNED BY public.scraping_jobs.id;


--
-- Name: scraping_raw_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scraping_raw_results (
    id integer NOT NULL,
    job_id integer NOT NULL,
    lead_id character varying NOT NULL,
    source character varying(50) NOT NULL,
    raw_json jsonb NOT NULL,
    normalized_status character varying(30),
    dedupe_key character varying(255),
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.scraping_raw_results OWNER TO postgres;

--
-- Name: scraping_raw_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scraping_raw_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraping_raw_results_id_seq OWNER TO postgres;

--
-- Name: scraping_raw_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scraping_raw_results_id_seq OWNED BY public.scraping_raw_results.id;


--
-- Name: lead_analysis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_analysis ALTER COLUMN id SET DEFAULT nextval('public.lead_analysis_id_seq'::regclass);


--
-- Name: lead_axis_scores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_axis_scores ALTER COLUMN id SET DEFAULT nextval('public.lead_axis_scores_id_seq'::regclass);


--
-- Name: lead_contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_contacts ALTER COLUMN id SET DEFAULT nextval('public.lead_contacts_id_seq'::regclass);


--
-- Name: lead_scores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_scores ALTER COLUMN id SET DEFAULT nextval('public.lead_scores_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: scraping_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_jobs ALTER COLUMN id SET DEFAULT nextval('public.scraping_jobs_id_seq'::regclass);


--
-- Name: scraping_raw_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_raw_results ALTER COLUMN id SET DEFAULT nextval('public.scraping_raw_results_id_seq'::regclass);


--
-- Data for Name: lead_analysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lead_analysis (id, lead_id, website_url, has_website, has_ssl, has_facebook, has_instagram, seo_title, seo_description, mobile_friendly, performance_score, analysis_status, analyzed_at) FROM stdin;
1	phase-1-5-demo-agency	\N	f	f	f	f	\N	\N	f	\N	SEEDED	2026-06-24 10:16:01.541968
2	phase-1-5-demo-bakery	https://example.test/demo-2	t	t	t	f	Demo title 2	\N	f	71	SEEDED	2026-06-24 10:16:01.541968
3	phase-1-5-demo-plumber	https://example.test/demo-3	t	t	f	f	Demo title 3	\N	t	72	SEEDED	2026-06-24 10:16:01.541968
5	phase-1-5-demo-plumber	https://example.com	t	t	f	f	Example Domain	\N	\N	\N	WEBSITE_NORMALIZED	2026-06-29 14:07:48.176694
15	curated-demo-fr-restaurant-septime-paris	https://www.septime-charonne.fr	t	t	f	t	. x X    Septime    X x .	Site officiel du restaurant Septime. 80 rue de Charonne, Paris 11, France.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:09:49.934666
10	curated-demo-tn-bakery-medina-tunis	https://www.paul.fr	t	t	t	t	PAUL : Maison de qualité depuis 1889	Vous pouvez maintenant commander et réserver votre repas, votre gâteau en ligne sur paul.fr . ✓ Voir les établissements éligibles au click and collect.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:09:51.066668
14	curated-demo-fr-bakery-poilane-paris	https://www.poilane.com	t	t	t	t	Boulangerie artisanale de pain au levain Paris\n    \n – Poilâne	Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:09:52.691204
13	curated-demo-tn-hotel-la-badira-hammamet	https://www.labadira.com	t	t	t	t	La badira - Accueil	Le nom "Badira : aussi lumineuse que la pleine lune" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:09:54.541157
16	curated-demo-fr-hotel-accor-paris-montparnasse	https://group.accor.com/en	t	t	t	t	Accor Group	Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:09:56.202605
17	curated-demo-tn-dental-clinic-sourire-sousse	https://www.doctolib.fr	t	t	t	t	Doctolib : Prenez rendez-vous en ligne chez un soignant	Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:15.910856
18	curated-demo-fr-dental-clinic-saint-lazare-paris	https://www.doctolib.fr	t	t	t	t	Doctolib : Prenez rendez-vous en ligne chez un soignant	Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:22.112807
19	curated-demo-tn-digital-agency-kif-lac-tunis	https://www.tapptic.com	t	t	f	f	Tapptic - Intelligent digital interfaces	Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:26.886607
20	curated-demo-tn-real-estate-mubawab-tunis	https://www.mubawab.tn	t	t	t	t	Immobilier Tunisie - 1er site immobilier - Mubawab	Mubawab est le site immobilier leader en Tunisie. Louez, achetez et vendez grâce à la plus large offre immobilière en Tunisie.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:28.210957
11	curated-demo-be-digital-agency-tapptic-brussels	https://www.tapptic.com	t	t	f	f	Tapptic - Intelligent digital interfaces	Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:30.669625
12	curated-demo-be-real-estate-century21-brussels	https://www.century21.be/nl	t	t	t	t	Nummer 1 netwerk van vastgoed makelaars in België en Luxemburg	Het leidende netwerk van vastgoed makelaars in België . Ontdek onze diensten en zoek een kantoor in je buurt.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:47.602838
21	curated-demo-be-plumber-facq-brussels	https://www.facq.be/fr/particuliers	t	t	t	t	Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq	Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:49.253081
22	curated-demo-fr-beauty-salon-dessange-paris	https://dessange.com	t	t	t	t	DESSANGE	Découvrez la marque DESSANGE : Des lignes de soins capillaires, de coiffants et de maquillage, signatures du style et de l'expertise DESSANGE	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:52.056674
23	curated-demo-fr-car-repair-norauto-lyon	https://www.norauto.fr	t	t	f	f	Just a moment...	\N	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:52.685699
24	curated-demo-be-law-office-liedekerke-brussels	https://liedekerke.com/en	t	t	t	t	Liedekerke - Solid International Service Capability | Liedekerke	Founded in 1965 by lawyers committed to legal excellence, Liedekerke is an independent law firm recognized for its leadership and expertise.	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:10:55.718068
25	curated-demo-tn-law-office-ferchiou-tunis	https://www.ferchioulaw.com	t	t	f	f	Ferchiou & Associés	Leading Business Law Firm In Tunisia	\N	\N	WEBSITE_NORMALIZED	2026-06-29 15:11:17.250769
46	curated-demo-tn-bakery-medina-tunis	https://www.paul.fr	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
47	curated-demo-fr-bakery-poilane-paris	https://www.poilane.com	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
48	curated-demo-tn-hotel-la-badira-hammamet	https://www.labadira.com	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
49	curated-demo-tn-restaurant-dar-sahel-sousse	\N	f	\N	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
50	curated-demo-fr-hotel-accor-paris-montparnasse	https://www.accor.com	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
51	curated-demo-fr-restaurant-septime-paris	https://www.septime-charonne.fr	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
52	curated-demo-tn-dental-clinic-sourire-sousse	https://www.doctolib.fr	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
53	curated-demo-fr-dental-clinic-saint-lazare-paris	https://www.doctolib.fr	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
54	curated-demo-tn-digital-agency-kif-lac-tunis	https://www.tapptic.com	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
55	curated-demo-tn-real-estate-mubawab-tunis	https://www.mubawab.tn	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
56	curated-demo-be-real-estate-century21-brussels	https://www.century21.be	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
57	curated-demo-be-digital-agency-tapptic-brussels	https://www.tapptic.com	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
58	curated-demo-tn-beauty-salon-nour-sfax	\N	f	\N	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
59	curated-demo-fr-beauty-salon-dessange-paris	https://www.dessange.com	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
60	curated-demo-tn-plumber-hydrotek-tunis	\N	f	\N	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
61	curated-demo-be-plumber-facq-brussels	https://www.facq.be	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
62	curated-demo-tn-law-office-ferchiou-tunis	https://www.ferchioulaw.com	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
63	curated-demo-tn-car-repair-carthage-auto-ariana	\N	f	\N	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
64	curated-demo-be-law-office-liedekerke-brussels	https://liedekerke.com	t	t	f	t	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
65	curated-demo-fr-car-repair-norauto-lyon	https://www.norauto.fr	t	t	f	f	\N	\N	\N	\N	CURATED_DEMO_AXIS_SEED	2026-06-29 01:00:00
\.


--
-- Data for Name: lead_axis_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lead_axis_scores (id, lead_id, analysis_id, axis, score, weight, weighted_score, is_available, score_type, "createdAt") FROM stdin;
21	phase-1-5-demo-agency	1	GMB	18	0.2	3.6	t	opportunity	2026-06-24 12:23:56.088098
22	phase-1-5-demo-agency	1	WEBSITE	24	0.35	8.4	t	opportunity	2026-06-24 12:23:56.088098
23	phase-1-5-demo-agency	1	SEO	29	0.25	7.25	t	opportunity	2026-06-24 12:23:56.088098
24	phase-1-5-demo-agency	1	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-24 12:23:56.088098
191	curated-demo-tn-bakery-medina-tunis	46	GMB	69	0.2	13.8	t	digital_maturity	2026-06-29 15:06:53.65252
192	curated-demo-tn-bakery-medina-tunis	46	WEBSITE	77	0.35	26.95	t	digital_maturity	2026-06-29 15:06:53.65252
193	curated-demo-tn-bakery-medina-tunis	46	SEO	61	0.25	15.25	t	digital_maturity	2026-06-29 15:06:53.65252
194	curated-demo-fr-bakery-poilane-paris	47	GMB	79	0.2	15.8	t	digital_maturity	2026-06-29 15:06:53.662189
195	curated-demo-tn-bakery-medina-tunis	46	SOCIAL	40	0.2	8	t	digital_maturity	2026-06-29 15:06:53.65252
196	curated-demo-fr-bakery-poilane-paris	47	WEBSITE	65	0.35	22.75	t	digital_maturity	2026-06-29 15:06:53.662189
197	curated-demo-tn-bakery-medina-tunis	46	GMB	22	0.2	4.4	t	opportunity	2026-06-29 15:06:53.65252
198	curated-demo-fr-bakery-poilane-paris	47	SEO	54	0.25	13.5	t	digital_maturity	2026-06-29 15:06:53.662189
199	curated-demo-tn-bakery-medina-tunis	46	WEBSITE	78	0.35	27.3	t	opportunity	2026-06-29 15:06:53.65252
200	curated-demo-fr-bakery-poilane-paris	47	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:06:53.662189
201	curated-demo-tn-bakery-medina-tunis	46	SEO	77	0.25	19.25	t	opportunity	2026-06-29 15:06:53.65252
202	curated-demo-fr-bakery-poilane-paris	47	GMB	48	0.2	9.6	t	opportunity	2026-06-29 15:06:53.662189
203	curated-demo-tn-bakery-medina-tunis	46	SOCIAL	67	0.2	13.4	t	opportunity	2026-06-29 15:06:53.65252
204	curated-demo-fr-bakery-poilane-paris	47	WEBSITE	70	0.35	24.5	t	opportunity	2026-06-29 15:06:53.662189
205	curated-demo-fr-bakery-poilane-paris	47	SEO	37	0.25	9.25	t	opportunity	2026-06-29 15:06:53.662189
206	curated-demo-fr-bakery-poilane-paris	47	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:06:53.662189
207	curated-demo-tn-hotel-la-badira-hammamet	48	GMB	61	0.2	12.2	t	digital_maturity	2026-06-29 15:07:52.143823
208	curated-demo-tn-hotel-la-badira-hammamet	48	WEBSITE	47	0.35	16.45	t	digital_maturity	2026-06-29 15:07:52.143823
209	curated-demo-tn-hotel-la-badira-hammamet	48	SEO	32	0.25	8	t	digital_maturity	2026-06-29 15:07:52.143823
210	curated-demo-tn-restaurant-dar-sahel-sousse	49	GMB	78	0.2	15.6	t	digital_maturity	2026-06-29 15:07:52.148964
211	curated-demo-tn-hotel-la-badira-hammamet	48	SOCIAL	32	0.2	6.4	t	digital_maturity	2026-06-29 15:07:52.143823
212	curated-demo-tn-restaurant-dar-sahel-sousse	49	WEBSITE	\N	0.35	\N	f	digital_maturity	2026-06-29 15:07:52.148964
213	curated-demo-tn-hotel-la-badira-hammamet	48	GMB	46	0.2	9.2	t	opportunity	2026-06-29 15:07:52.143823
214	curated-demo-fr-hotel-accor-paris-montparnasse	50	GMB	61	0.2	12.2	t	digital_maturity	2026-06-29 15:07:52.151258
1	phase-1-5-demo-bakery	2	GMB	70	0.2	14	t	digital_maturity	2026-06-24 12:23:56.088098
2	phase-1-5-demo-bakery	2	WEBSITE	55	0.35	19.25	t	digital_maturity	2026-06-24 12:23:56.088098
3	phase-1-5-demo-bakery	2	SEO	40	0.25	10	t	digital_maturity	2026-06-24 12:23:56.088098
4	phase-1-5-demo-bakery	2	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-24 12:23:56.088098
5	phase-1-5-demo-bakery	2	GMB	30	0.2	6	t	opportunity	2026-06-24 12:23:56.088098
6	phase-1-5-demo-bakery	2	WEBSITE	65	0.35	22.75	t	opportunity	2026-06-24 12:23:56.088098
7	phase-1-5-demo-bakery	2	SEO	60	0.25	15	t	opportunity	2026-06-24 12:23:56.088098
8	phase-1-5-demo-bakery	2	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-24 12:23:56.088098
9	phase-1-5-demo-plumber	3	GMB	62	0.2	12.4	t	digital_maturity	2026-06-24 12:23:56.088098
10	phase-1-5-demo-plumber	3	WEBSITE	68	0.35	23.8	t	digital_maturity	2026-06-24 12:23:56.088098
11	phase-1-5-demo-plumber	3	SEO	52	0.25	13	t	digital_maturity	2026-06-24 12:23:56.088098
12	phase-1-5-demo-plumber	3	SOCIAL	45	0.2	9	t	digital_maturity	2026-06-24 12:23:56.088098
13	phase-1-5-demo-plumber	3	GMB	38	0.2	7.6	t	opportunity	2026-06-24 12:23:56.088098
14	phase-1-5-demo-plumber	3	WEBSITE	32	0.35	11.2	t	opportunity	2026-06-24 12:23:56.088098
15	phase-1-5-demo-plumber	3	SEO	48	0.25	12	t	opportunity	2026-06-24 12:23:56.088098
16	phase-1-5-demo-plumber	3	SOCIAL	55	0.2	11	t	opportunity	2026-06-24 12:23:56.088098
17	phase-1-5-demo-agency	1	GMB	82	0.2	16.4	t	digital_maturity	2026-06-24 12:23:56.088098
18	phase-1-5-demo-agency	1	WEBSITE	76	0.35	26.6	t	digital_maturity	2026-06-24 12:23:56.088098
19	phase-1-5-demo-agency	1	SEO	71	0.25	17.75	t	digital_maturity	2026-06-24 12:23:56.088098
20	phase-1-5-demo-agency	1	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-24 12:23:56.088098
215	curated-demo-tn-restaurant-dar-sahel-sousse	49	SEO	\N	0.25	\N	f	digital_maturity	2026-06-29 15:07:52.148964
216	curated-demo-tn-hotel-la-badira-hammamet	48	WEBSITE	76	0.35	26.6	t	opportunity	2026-06-29 15:07:52.143823
217	curated-demo-tn-hotel-la-badira-hammamet	48	SEO	50	0.25	12.5	t	opportunity	2026-06-29 15:07:52.143823
218	curated-demo-tn-restaurant-dar-sahel-sousse	49	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:07:52.148964
219	curated-demo-fr-hotel-accor-paris-montparnasse	50	WEBSITE	37	0.35	12.95	t	digital_maturity	2026-06-29 15:07:52.151258
220	curated-demo-tn-hotel-la-badira-hammamet	48	SOCIAL	38	0.2	7.6	t	opportunity	2026-06-29 15:07:52.143823
221	curated-demo-tn-restaurant-dar-sahel-sousse	49	GMB	35	0.2	7	t	opportunity	2026-06-29 15:07:52.148964
222	curated-demo-tn-restaurant-dar-sahel-sousse	49	WEBSITE	\N	0.35	\N	f	opportunity	2026-06-29 15:07:52.148964
223	curated-demo-fr-hotel-accor-paris-montparnasse	50	SEO	59	0.25	14.75	t	digital_maturity	2026-06-29 15:07:52.151258
224	curated-demo-fr-restaurant-septime-paris	51	GMB	61	0.2	12.2	t	digital_maturity	2026-06-29 15:07:52.15786
225	curated-demo-tn-restaurant-dar-sahel-sousse	49	SEO	\N	0.25	\N	f	opportunity	2026-06-29 15:07:52.148964
226	curated-demo-fr-hotel-accor-paris-montparnasse	50	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:07:52.151258
227	curated-demo-fr-restaurant-septime-paris	51	WEBSITE	61	0.35	21.35	t	digital_maturity	2026-06-29 15:07:52.15786
228	curated-demo-fr-hotel-accor-paris-montparnasse	50	GMB	26	0.2	5.2	t	opportunity	2026-06-29 15:07:52.151258
229	curated-demo-tn-restaurant-dar-sahel-sousse	49	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:07:52.148964
230	curated-demo-fr-restaurant-septime-paris	51	SEO	34	0.25	8.5	t	digital_maturity	2026-06-29 15:07:52.15786
231	curated-demo-fr-hotel-accor-paris-montparnasse	50	WEBSITE	35	0.35	12.25	t	opportunity	2026-06-29 15:07:52.151258
232	curated-demo-fr-restaurant-septime-paris	51	SOCIAL	63	0.2	12.6	t	digital_maturity	2026-06-29 15:07:52.15786
233	curated-demo-fr-hotel-accor-paris-montparnasse	50	SEO	81	0.25	20.25	t	opportunity	2026-06-29 15:07:52.151258
235	curated-demo-fr-hotel-accor-paris-montparnasse	50	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:07:52.151258
234	curated-demo-fr-restaurant-septime-paris	51	GMB	46	0.2	9.2	t	opportunity	2026-06-29 15:07:52.15786
236	curated-demo-fr-restaurant-septime-paris	51	WEBSITE	32	0.35	11.2	t	opportunity	2026-06-29 15:07:52.15786
237	curated-demo-fr-restaurant-septime-paris	51	SEO	83	0.25	20.75	t	opportunity	2026-06-29 15:07:52.15786
238	curated-demo-fr-restaurant-septime-paris	51	SOCIAL	60	0.2	12	t	opportunity	2026-06-29 15:07:52.15786
240	curated-demo-fr-dental-clinic-saint-lazare-paris	53	GMB	85	0.2	17	t	digital_maturity	2026-06-29 15:07:52.283971
242	curated-demo-fr-dental-clinic-saint-lazare-paris	53	WEBSITE	35	0.35	12.25	t	digital_maturity	2026-06-29 15:07:52.283971
244	curated-demo-fr-dental-clinic-saint-lazare-paris	53	SEO	58	0.25	14.5	t	digital_maturity	2026-06-29 15:07:52.283971
246	curated-demo-fr-dental-clinic-saint-lazare-paris	53	SOCIAL	31	0.2	6.2	t	digital_maturity	2026-06-29 15:07:52.283971
248	curated-demo-fr-dental-clinic-saint-lazare-paris	53	GMB	44	0.2	8.8	t	opportunity	2026-06-29 15:07:52.283971
250	curated-demo-fr-dental-clinic-saint-lazare-paris	53	WEBSITE	79	0.35	27.65	t	opportunity	2026-06-29 15:07:52.283971
252	curated-demo-fr-dental-clinic-saint-lazare-paris	53	SEO	69	0.25	17.25	t	opportunity	2026-06-29 15:07:52.283971
254	curated-demo-fr-dental-clinic-saint-lazare-paris	53	SOCIAL	45	0.2	9	t	opportunity	2026-06-29 15:07:52.283971
239	curated-demo-tn-dental-clinic-sourire-sousse	52	GMB	72	0.2	14.4	t	digital_maturity	2026-06-29 15:07:52.283983
241	curated-demo-tn-dental-clinic-sourire-sousse	52	WEBSITE	52	0.35	18.2	t	digital_maturity	2026-06-29 15:07:52.283983
243	curated-demo-tn-dental-clinic-sourire-sousse	52	SEO	57	0.25	14.25	t	digital_maturity	2026-06-29 15:07:52.283983
245	curated-demo-tn-dental-clinic-sourire-sousse	52	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:07:52.283983
247	curated-demo-tn-dental-clinic-sourire-sousse	52	GMB	47	0.2	9.4	t	opportunity	2026-06-29 15:07:52.283983
249	curated-demo-tn-dental-clinic-sourire-sousse	52	WEBSITE	59	0.35	20.65	t	opportunity	2026-06-29 15:07:52.283983
251	curated-demo-tn-dental-clinic-sourire-sousse	52	SEO	45	0.25	11.25	t	opportunity	2026-06-29 15:07:52.283983
253	curated-demo-tn-dental-clinic-sourire-sousse	52	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:07:52.283983
255	curated-demo-tn-digital-agency-kif-lac-tunis	54	GMB	64	0.2	12.8	t	digital_maturity	2026-06-29 15:08:14.248639
256	curated-demo-tn-digital-agency-kif-lac-tunis	54	WEBSITE	76	0.35	26.6	t	digital_maturity	2026-06-29 15:08:14.248639
257	curated-demo-tn-real-estate-mubawab-tunis	55	GMB	73	0.2	14.6	t	digital_maturity	2026-06-29 15:08:14.253743
258	curated-demo-tn-digital-agency-kif-lac-tunis	54	SEO	48	0.25	12	t	digital_maturity	2026-06-29 15:08:14.248639
259	curated-demo-tn-digital-agency-kif-lac-tunis	54	SOCIAL	54	0.2	10.8	t	digital_maturity	2026-06-29 15:08:14.248639
260	curated-demo-tn-real-estate-mubawab-tunis	55	WEBSITE	77	0.35	26.95	t	digital_maturity	2026-06-29 15:08:14.253743
261	curated-demo-tn-digital-agency-kif-lac-tunis	54	GMB	43	0.2	8.6	t	opportunity	2026-06-29 15:08:14.248639
262	curated-demo-be-real-estate-century21-brussels	56	GMB	62	0.2	12.4	t	digital_maturity	2026-06-29 15:08:14.258905
263	curated-demo-tn-digital-agency-kif-lac-tunis	54	WEBSITE	78	0.35	27.3	t	opportunity	2026-06-29 15:08:14.248639
264	curated-demo-tn-real-estate-mubawab-tunis	55	SEO	51	0.25	12.75	t	digital_maturity	2026-06-29 15:08:14.253743
265	curated-demo-be-real-estate-century21-brussels	56	WEBSITE	78	0.35	27.3	t	digital_maturity	2026-06-29 15:08:14.258905
266	curated-demo-be-digital-agency-tapptic-brussels	57	GMB	71	0.2	14.2	t	digital_maturity	2026-06-29 15:08:14.25952
267	curated-demo-be-real-estate-century21-brussels	56	SEO	73	0.25	18.25	t	digital_maturity	2026-06-29 15:08:14.258905
268	curated-demo-tn-digital-agency-kif-lac-tunis	54	SEO	65	0.25	16.25	t	opportunity	2026-06-29 15:08:14.248639
269	curated-demo-tn-real-estate-mubawab-tunis	55	SOCIAL	58	0.2	11.6	t	digital_maturity	2026-06-29 15:08:14.253743
270	curated-demo-be-digital-agency-tapptic-brussels	57	WEBSITE	53	0.35	18.55	t	digital_maturity	2026-06-29 15:08:14.25952
271	curated-demo-be-real-estate-century21-brussels	56	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:14.258905
272	curated-demo-tn-digital-agency-kif-lac-tunis	54	SOCIAL	63	0.2	12.6	t	opportunity	2026-06-29 15:08:14.248639
273	curated-demo-be-real-estate-century21-brussels	56	GMB	41	0.2	8.2	t	opportunity	2026-06-29 15:08:14.258905
274	curated-demo-tn-real-estate-mubawab-tunis	55	GMB	40	0.2	8	t	opportunity	2026-06-29 15:08:14.253743
275	curated-demo-be-digital-agency-tapptic-brussels	57	SEO	51	0.25	12.75	t	digital_maturity	2026-06-29 15:08:14.25952
276	curated-demo-be-real-estate-century21-brussels	56	WEBSITE	55	0.35	19.25	t	opportunity	2026-06-29 15:08:14.258905
277	curated-demo-tn-real-estate-mubawab-tunis	55	WEBSITE	46	0.35	16.1	t	opportunity	2026-06-29 15:08:14.253743
278	curated-demo-be-digital-agency-tapptic-brussels	57	SOCIAL	49	0.2	9.8	t	digital_maturity	2026-06-29 15:08:14.25952
279	curated-demo-be-real-estate-century21-brussels	56	SEO	48	0.25	12	t	opportunity	2026-06-29 15:08:14.258905
280	curated-demo-tn-real-estate-mubawab-tunis	55	SEO	41	0.25	10.25	t	opportunity	2026-06-29 15:08:14.253743
281	curated-demo-be-digital-agency-tapptic-brussels	57	GMB	22	0.2	4.4	t	opportunity	2026-06-29 15:08:14.25952
282	curated-demo-be-real-estate-century21-brussels	56	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:14.258905
283	curated-demo-tn-real-estate-mubawab-tunis	55	SOCIAL	75	0.2	15	t	opportunity	2026-06-29 15:08:14.253743
284	curated-demo-be-digital-agency-tapptic-brussels	57	WEBSITE	78	0.35	27.3	t	opportunity	2026-06-29 15:08:14.25952
285	curated-demo-be-digital-agency-tapptic-brussels	57	SEO	50	0.25	12.5	t	opportunity	2026-06-29 15:08:14.25952
286	curated-demo-be-digital-agency-tapptic-brussels	57	SOCIAL	62	0.2	12.4	t	opportunity	2026-06-29 15:08:14.25952
287	curated-demo-fr-beauty-salon-dessange-paris	59	GMB	79	0.2	15.8	t	digital_maturity	2026-06-29 15:08:14.39427
288	curated-demo-tn-beauty-salon-nour-sfax	58	GMB	72	0.2	14.4	t	digital_maturity	2026-06-29 15:08:14.394212
289	curated-demo-fr-beauty-salon-dessange-paris	59	WEBSITE	57	0.35	19.95	t	digital_maturity	2026-06-29 15:08:14.39427
290	curated-demo-tn-beauty-salon-nour-sfax	58	WEBSITE	\N	0.35	\N	f	digital_maturity	2026-06-29 15:08:14.394212
291	curated-demo-fr-beauty-salon-dessange-paris	59	SEO	58	0.25	14.5	t	digital_maturity	2026-06-29 15:08:14.39427
292	curated-demo-tn-beauty-salon-nour-sfax	58	SEO	\N	0.25	\N	f	digital_maturity	2026-06-29 15:08:14.394212
293	curated-demo-fr-beauty-salon-dessange-paris	59	SOCIAL	49	0.2	9.8	t	digital_maturity	2026-06-29 15:08:14.39427
294	curated-demo-tn-beauty-salon-nour-sfax	58	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:14.394212
295	curated-demo-fr-beauty-salon-dessange-paris	59	GMB	16	0.2	3.2	t	opportunity	2026-06-29 15:08:14.39427
296	curated-demo-tn-plumber-hydrotek-tunis	60	GMB	76	0.2	15.2	t	digital_maturity	2026-06-29 15:08:14.39898
297	curated-demo-fr-beauty-salon-dessange-paris	59	WEBSITE	71	0.35	24.85	t	opportunity	2026-06-29 15:08:14.39427
298	curated-demo-be-plumber-facq-brussels	61	GMB	82	0.2	16.4	t	digital_maturity	2026-06-29 15:08:14.399056
299	curated-demo-tn-beauty-salon-nour-sfax	58	GMB	15	0.2	3	t	opportunity	2026-06-29 15:08:14.394212
300	curated-demo-tn-plumber-hydrotek-tunis	60	WEBSITE	\N	0.35	\N	f	digital_maturity	2026-06-29 15:08:14.39898
301	curated-demo-fr-beauty-salon-dessange-paris	59	SEO	44	0.25	11	t	opportunity	2026-06-29 15:08:14.39427
302	curated-demo-be-plumber-facq-brussels	61	WEBSITE	70	0.35	24.5	t	digital_maturity	2026-06-29 15:08:14.399056
303	curated-demo-tn-beauty-salon-nour-sfax	58	WEBSITE	\N	0.35	\N	f	opportunity	2026-06-29 15:08:14.394212
304	curated-demo-fr-beauty-salon-dessange-paris	59	SOCIAL	65	0.2	13	t	opportunity	2026-06-29 15:08:14.39427
305	curated-demo-tn-plumber-hydrotek-tunis	60	SEO	\N	0.25	\N	f	digital_maturity	2026-06-29 15:08:14.39898
306	curated-demo-be-plumber-facq-brussels	61	SEO	75	0.25	18.75	t	digital_maturity	2026-06-29 15:08:14.399056
307	curated-demo-tn-beauty-salon-nour-sfax	58	SEO	\N	0.25	\N	f	opportunity	2026-06-29 15:08:14.394212
308	curated-demo-tn-plumber-hydrotek-tunis	60	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:14.39898
309	curated-demo-tn-beauty-salon-nour-sfax	58	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:14.394212
310	curated-demo-be-plumber-facq-brussels	61	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:14.399056
312	curated-demo-be-plumber-facq-brussels	61	GMB	45	0.2	9	t	opportunity	2026-06-29 15:08:14.399056
315	curated-demo-be-plumber-facq-brussels	61	WEBSITE	78	0.35	27.3	t	opportunity	2026-06-29 15:08:14.399056
317	curated-demo-be-plumber-facq-brussels	61	SEO	58	0.25	14.5	t	opportunity	2026-06-29 15:08:14.399056
318	curated-demo-be-plumber-facq-brussels	61	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:14.399056
311	curated-demo-tn-plumber-hydrotek-tunis	60	GMB	29	0.2	5.8	t	opportunity	2026-06-29 15:08:14.39898
313	curated-demo-tn-plumber-hydrotek-tunis	60	WEBSITE	\N	0.35	\N	f	opportunity	2026-06-29 15:08:14.39898
314	curated-demo-tn-plumber-hydrotek-tunis	60	SEO	\N	0.25	\N	f	opportunity	2026-06-29 15:08:14.39898
316	curated-demo-tn-plumber-hydrotek-tunis	60	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:14.39898
319	curated-demo-tn-law-office-ferchiou-tunis	62	GMB	77	0.2	15.4	t	digital_maturity	2026-06-29 15:08:30.902454
320	curated-demo-tn-car-repair-carthage-auto-ariana	63	GMB	79	0.2	15.8	t	digital_maturity	2026-06-29 15:08:30.902983
321	curated-demo-tn-law-office-ferchiou-tunis	62	WEBSITE	67	0.35	23.45	t	digital_maturity	2026-06-29 15:08:30.902454
322	curated-demo-tn-car-repair-carthage-auto-ariana	63	WEBSITE	\N	0.35	\N	f	digital_maturity	2026-06-29 15:08:30.902983
323	curated-demo-tn-law-office-ferchiou-tunis	62	SEO	60	0.25	15	t	digital_maturity	2026-06-29 15:08:30.902454
324	curated-demo-tn-law-office-ferchiou-tunis	62	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:30.902454
325	curated-demo-tn-car-repair-carthage-auto-ariana	63	SEO	\N	0.25	\N	f	digital_maturity	2026-06-29 15:08:30.902983
326	curated-demo-tn-law-office-ferchiou-tunis	62	GMB	46	0.2	9.2	t	opportunity	2026-06-29 15:08:30.902454
327	curated-demo-tn-car-repair-carthage-auto-ariana	63	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:30.902983
328	curated-demo-be-law-office-liedekerke-brussels	64	GMB	68	0.2	13.6	t	digital_maturity	2026-06-29 15:08:30.914497
329	curated-demo-tn-law-office-ferchiou-tunis	62	WEBSITE	43	0.35	15.05	t	opportunity	2026-06-29 15:08:30.902454
330	curated-demo-tn-car-repair-carthage-auto-ariana	63	GMB	22	0.2	4.4	t	opportunity	2026-06-29 15:08:30.902983
331	curated-demo-fr-car-repair-norauto-lyon	65	GMB	76	0.2	15.2	t	digital_maturity	2026-06-29 15:08:30.916306
332	curated-demo-be-law-office-liedekerke-brussels	64	WEBSITE	78	0.35	27.3	t	digital_maturity	2026-06-29 15:08:30.914497
333	curated-demo-tn-law-office-ferchiou-tunis	62	SEO	83	0.25	20.75	t	opportunity	2026-06-29 15:08:30.902454
334	curated-demo-tn-car-repair-carthage-auto-ariana	63	WEBSITE	\N	0.35	\N	f	opportunity	2026-06-29 15:08:30.902983
335	curated-demo-fr-car-repair-norauto-lyon	65	WEBSITE	50	0.35	17.5	t	digital_maturity	2026-06-29 15:08:30.916306
336	curated-demo-be-law-office-liedekerke-brussels	64	SEO	47	0.25	11.75	t	digital_maturity	2026-06-29 15:08:30.914497
337	curated-demo-tn-law-office-ferchiou-tunis	62	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:30.902454
338	curated-demo-tn-car-repair-carthage-auto-ariana	63	SEO	\N	0.25	\N	f	opportunity	2026-06-29 15:08:30.902983
339	curated-demo-fr-car-repair-norauto-lyon	65	SEO	57	0.25	14.25	t	digital_maturity	2026-06-29 15:08:30.916306
340	curated-demo-be-law-office-liedekerke-brussels	64	SOCIAL	70	0.2	14	t	digital_maturity	2026-06-29 15:08:30.914497
341	curated-demo-tn-car-repair-carthage-auto-ariana	63	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:30.902983
342	curated-demo-fr-car-repair-norauto-lyon	65	SOCIAL	\N	0.2	\N	f	digital_maturity	2026-06-29 15:08:30.916306
343	curated-demo-be-law-office-liedekerke-brussels	64	GMB	35	0.2	7	t	opportunity	2026-06-29 15:08:30.914497
344	curated-demo-fr-car-repair-norauto-lyon	65	GMB	41	0.2	8.2	t	opportunity	2026-06-29 15:08:30.916306
345	curated-demo-be-law-office-liedekerke-brussels	64	WEBSITE	73	0.35	25.55	t	opportunity	2026-06-29 15:08:30.914497
346	curated-demo-fr-car-repair-norauto-lyon	65	WEBSITE	76	0.35	26.6	t	opportunity	2026-06-29 15:08:30.916306
347	curated-demo-be-law-office-liedekerke-brussels	64	SEO	42	0.25	10.5	t	opportunity	2026-06-29 15:08:30.914497
348	curated-demo-fr-car-repair-norauto-lyon	65	SEO	39	0.25	9.75	t	opportunity	2026-06-29 15:08:30.916306
349	curated-demo-be-law-office-liedekerke-brussels	64	SOCIAL	42	0.2	8.4	t	opportunity	2026-06-29 15:08:30.914497
350	curated-demo-fr-car-repair-norauto-lyon	65	SOCIAL	\N	0.2	\N	f	opportunity	2026-06-29 15:08:30.916306
\.


--
-- Data for Name: lead_contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lead_contacts (id, lead_id, name, email, phone, source, "createdAt") FROM stdin;
1	phase-1-5-demo-agency	Demo Contact 1	demo@example.test	\N	phase-1.5-seed	2026-06-24 10:16:01.541968
2	phase-1-5-demo-bakery	Demo Contact 2	\N	+216 00 000 102	phase-1.5-seed	2026-06-24 10:16:01.541968
3	phase-1-5-demo-plumber	Demo Contact 3	\N	\N	phase-1.5-seed	2026-06-24 10:16:01.541968
10	curated-demo-tn-hotel-la-badira-hammamet	\N	contact@labadira.com	\N	website	2026-06-29 14:37:17.998976
11	curated-demo-tn-hotel-la-badira-hammamet	\N	\N	2167 0018 180	website	2026-06-29 14:37:17.998976
12	curated-demo-tn-hotel-la-badira-hammamet	\N	\N	2169 4866 672	website	2026-06-29 14:37:17.998976
13	curated-demo-fr-restaurant-septime-paris	\N	confirmation@septime-charonne.fr	\N	website	2026-06-29 14:37:29.561045
14	curated-demo-fr-restaurant-septime-paris	\N	presse@septime-charonne.fr	\N	website	2026-06-29 14:37:29.561045
15	curated-demo-fr-restaurant-septime-paris	\N	travailler@septime-charonne.fr	\N	website	2026-06-29 14:37:29.561045
16	curated-demo-fr-hotel-accor-paris-montparnasse	\N	\N	1106 2026	website	2026-06-29 14:37:30.469982
17	curated-demo-fr-hotel-accor-paris-montparnasse	\N	\N	1806 2026	website	2026-06-29 14:37:30.469982
18	curated-demo-fr-hotel-accor-paris-montparnasse	\N	\N	2406 2026	website	2026-06-29 14:37:30.469982
19	curated-demo-fr-hotel-accor-paris-montparnasse	\N	\N	2606 2026	website	2026-06-29 14:37:30.469982
20	curated-demo-be-law-office-liedekerke-brussels	\N	info@liedekerke.com	\N	website	2026-06-29 14:38:04.364843
21	curated-demo-be-law-office-liedekerke-brussels	\N	\N	+3225 5115 15	website	2026-06-29 14:38:04.364843
22	curated-demo-tn-law-office-ferchiou-tunis	\N	contact@ferchioulaw.com	\N	website	2026-06-29 14:38:18.897947
23	curated-demo-tn-law-office-ferchiou-tunis	\N	\N	+2167 1120 500	website	2026-06-29 14:38:18.897947
24	curated-demo-tn-law-office-ferchiou-tunis	\N	\N	+2167 1350 028	website	2026-06-29 14:38:18.897947
\.


--
-- Data for Name: lead_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lead_scores (id, lead_id, analysis_id, period_type, digital_maturity, opportunity, analysis_cost, "createdAt", score_date) FROM stdin;
3	phase-1-5-demo-bakery	2	current	32.00	68.00	1.20	2026-06-24 10:16:01.541968	2026-06-24
4	phase-1-5-demo-bakery	2	monthly	38.00	62.00	4.80	2026-06-24 10:16:01.541968	2026-06-24
7	phase-1-5-demo-bakery	2	daily	42.00	38.00	5.00	2026-06-24 13:38:03.626885	2026-06-01
8	phase-1-5-demo-bakery	2	daily	42.52	38.90	5.10	2026-06-24 13:38:03.626885	2026-06-02
9	phase-1-5-demo-bakery	2	daily	43.03	39.79	5.20	2026-06-24 13:38:03.626885	2026-06-03
10	phase-1-5-demo-bakery	2	daily	43.55	40.69	5.30	2026-06-24 13:38:03.626885	2026-06-04
6	phase-1-5-demo-plumber	3	monthly	55.00	45.00	5.25	2026-06-24 10:16:01.541968	2026-06-24
37	phase-1-5-demo-plumber	3	daily	35.00	45.00	4.00	2026-06-24 13:38:03.626885	2026-06-01
38	phase-1-5-demo-plumber	3	daily	35.48	45.86	4.10	2026-06-24 13:38:03.626885	2026-06-02
39	phase-1-5-demo-plumber	3	daily	35.97	46.72	4.20	2026-06-24 13:38:03.626885	2026-06-03
40	phase-1-5-demo-plumber	3	daily	36.45	47.59	4.30	2026-06-24 13:38:03.626885	2026-06-04
41	phase-1-5-demo-plumber	3	daily	36.93	48.45	4.40	2026-06-24 13:38:03.626885	2026-06-05
42	phase-1-5-demo-plumber	3	daily	37.41	49.31	4.50	2026-06-24 13:38:03.626885	2026-06-06
43	phase-1-5-demo-plumber	3	daily	37.90	50.17	4.60	2026-06-24 13:38:03.626885	2026-06-07
44	phase-1-5-demo-plumber	3	daily	38.38	51.03	4.70	2026-06-24 13:38:03.626885	2026-06-08
45	phase-1-5-demo-plumber	3	daily	38.86	51.90	4.80	2026-06-24 13:38:03.626885	2026-06-09
46	phase-1-5-demo-plumber	3	daily	39.34	52.76	4.90	2026-06-24 13:38:03.626885	2026-06-10
47	phase-1-5-demo-plumber	3	daily	39.83	53.62	5.00	2026-06-24 13:38:03.626885	2026-06-11
48	phase-1-5-demo-plumber	3	daily	40.31	54.48	5.10	2026-06-24 13:38:03.626885	2026-06-12
49	phase-1-5-demo-plumber	3	daily	40.79	55.34	5.20	2026-06-24 13:38:03.626885	2026-06-13
50	phase-1-5-demo-plumber	3	daily	41.28	56.21	5.30	2026-06-24 13:38:03.626885	2026-06-14
51	phase-1-5-demo-plumber	3	daily	41.76	57.07	5.40	2026-06-24 13:38:03.626885	2026-06-15
52	phase-1-5-demo-plumber	3	daily	42.24	57.93	5.50	2026-06-24 13:38:03.626885	2026-06-16
53	phase-1-5-demo-plumber	3	daily	42.72	58.79	5.60	2026-06-24 13:38:03.626885	2026-06-17
54	phase-1-5-demo-plumber	3	daily	43.21	59.66	5.70	2026-06-24 13:38:03.626885	2026-06-18
55	phase-1-5-demo-plumber	3	daily	43.69	60.52	5.80	2026-06-24 13:38:03.626885	2026-06-19
56	phase-1-5-demo-plumber	3	daily	44.17	61.38	5.90	2026-06-24 13:38:03.626885	2026-06-20
89	phase-1-5-demo-agency	1	daily	71.38	43.66	8.20	2026-06-24 13:38:03.626885	2026-06-23
90	phase-1-5-demo-agency	1	daily	71.90	44.28	8.30	2026-06-24 13:38:03.626885	2026-06-24
91	phase-1-5-demo-agency	1	daily	72.41	44.90	8.40	2026-06-24 13:38:03.626885	2026-06-25
92	phase-1-5-demo-agency	1	daily	72.93	45.52	8.50	2026-06-24 13:38:03.626885	2026-06-26
93	phase-1-5-demo-agency	1	daily	73.45	46.14	8.60	2026-06-24 13:38:03.626885	2026-06-27
94	phase-1-5-demo-agency	1	daily	73.97	46.76	8.70	2026-06-24 13:38:03.626885	2026-06-28
95	phase-1-5-demo-agency	1	daily	74.48	47.38	8.80	2026-06-24 13:38:03.626885	2026-06-29
96	phase-1-5-demo-agency	1	daily	75.00	48.00	8.90	2026-06-24 13:38:03.626885	2026-06-30
118	curated-demo-tn-bakery-medina-tunis	46	current	54	40	\N	2026-06-29 15:06:53.65252	2026-06-29
121	curated-demo-tn-restaurant-dar-sahel-sousse	49	current	57	38	\N	2026-06-29 15:07:52.148964	2026-06-29
126	curated-demo-tn-digital-agency-kif-lac-tunis	54	current	57	49	\N	2026-06-29 15:08:14.248639	2026-06-29
129	curated-demo-be-digital-agency-tapptic-brussels	57	current	58	45	\N	2026-06-29 15:08:14.25952	2026-06-29
130	curated-demo-tn-beauty-salon-nour-sfax	58	current	71	51	\N	2026-06-29 15:08:14.394212	2026-06-29
133	curated-demo-be-plumber-facq-brussels	61	current	77	42	\N	2026-06-29 15:08:14.399056	2026-06-29
136	curated-demo-be-law-office-liedekerke-brussels	64	current	65	63	\N	2026-06-29 15:08:30.914497	2026-06-29
119	curated-demo-fr-bakery-poilane-paris	47	current	50	69	\N	2026-06-29 15:06:53.662189	2026-06-29
122	curated-demo-fr-hotel-accor-paris-montparnasse	50	current	78	35	\N	2026-06-29 15:07:52.151258	2026-06-29
127	curated-demo-tn-real-estate-mubawab-tunis	55	current	56	35	\N	2026-06-29 15:08:14.253743	2026-06-29
132	curated-demo-tn-plumber-hydrotek-tunis	60	current	69	36	\N	2026-06-29 15:08:14.39898	2026-06-29
134	curated-demo-tn-law-office-ferchiou-tunis	62	current	46	33	\N	2026-06-29 15:08:30.902454	2026-06-29
137	curated-demo-fr-car-repair-norauto-lyon	65	current	63	41	\N	2026-06-29 15:08:30.916306	2026-06-29
11	phase-1-5-demo-bakery	2	daily	44.07	41.59	5.40	2026-06-24 13:38:03.626885	2026-06-05
12	phase-1-5-demo-bakery	2	daily	44.59	42.48	5.50	2026-06-24 13:38:03.626885	2026-06-06
13	phase-1-5-demo-bakery	2	daily	45.10	43.38	5.60	2026-06-24 13:38:03.626885	2026-06-07
14	phase-1-5-demo-bakery	2	daily	45.62	44.28	5.70	2026-06-24 13:38:03.626885	2026-06-08
15	phase-1-5-demo-bakery	2	daily	46.14	45.17	5.80	2026-06-24 13:38:03.626885	2026-06-09
16	phase-1-5-demo-bakery	2	daily	46.66	46.07	5.90	2026-06-24 13:38:03.626885	2026-06-10
17	phase-1-5-demo-bakery	2	daily	47.17	46.97	6.00	2026-06-24 13:38:03.626885	2026-06-11
18	phase-1-5-demo-bakery	2	daily	47.69	47.86	6.10	2026-06-24 13:38:03.626885	2026-06-12
19	phase-1-5-demo-bakery	2	daily	48.21	48.76	6.20	2026-06-24 13:38:03.626885	2026-06-13
20	phase-1-5-demo-bakery	2	daily	48.72	49.66	6.30	2026-06-24 13:38:03.626885	2026-06-14
21	phase-1-5-demo-bakery	2	daily	49.24	50.55	6.40	2026-06-24 13:38:03.626885	2026-06-15
22	phase-1-5-demo-bakery	2	daily	49.76	51.45	6.50	2026-06-24 13:38:03.626885	2026-06-16
23	phase-1-5-demo-bakery	2	daily	50.28	52.34	6.60	2026-06-24 13:38:03.626885	2026-06-17
24	phase-1-5-demo-bakery	2	daily	50.79	53.24	6.70	2026-06-24 13:38:03.626885	2026-06-18
25	phase-1-5-demo-bakery	2	daily	51.31	54.14	6.80	2026-06-24 13:38:03.626885	2026-06-19
26	phase-1-5-demo-bakery	2	daily	51.83	55.03	6.90	2026-06-24 13:38:03.626885	2026-06-20
27	phase-1-5-demo-bakery	2	daily	52.34	55.93	7.00	2026-06-24 13:38:03.626885	2026-06-21
28	phase-1-5-demo-bakery	2	daily	52.86	56.83	7.10	2026-06-24 13:38:03.626885	2026-06-22
29	phase-1-5-demo-bakery	2	daily	53.38	57.72	7.20	2026-06-24 13:38:03.626885	2026-06-23
30	phase-1-5-demo-bakery	2	daily	53.90	58.62	7.30	2026-06-24 13:38:03.626885	2026-06-24
31	phase-1-5-demo-bakery	2	daily	54.41	59.52	7.40	2026-06-24 13:38:03.626885	2026-06-25
32	phase-1-5-demo-bakery	2	daily	54.93	60.41	7.50	2026-06-24 13:38:03.626885	2026-06-26
33	phase-1-5-demo-bakery	2	daily	55.45	61.31	7.60	2026-06-24 13:38:03.626885	2026-06-27
34	phase-1-5-demo-bakery	2	daily	55.97	62.21	7.70	2026-06-24 13:38:03.626885	2026-06-28
35	phase-1-5-demo-bakery	2	daily	56.48	63.10	7.80	2026-06-24 13:38:03.626885	2026-06-29
36	phase-1-5-demo-bakery	2	daily	57.00	64.00	7.90	2026-06-24 13:38:03.626885	2026-06-30
5	phase-1-5-demo-plumber	3	current	51.00	49.00	1.50	2026-06-24 10:16:01.541968	2026-06-24
57	phase-1-5-demo-plumber	3	daily	44.66	62.24	6.00	2026-06-24 13:38:03.626885	2026-06-21
58	phase-1-5-demo-plumber	3	daily	45.14	63.10	6.10	2026-06-24 13:38:03.626885	2026-06-22
59	phase-1-5-demo-plumber	3	daily	45.62	63.97	6.20	2026-06-24 13:38:03.626885	2026-06-23
60	phase-1-5-demo-plumber	3	daily	46.10	64.83	6.30	2026-06-24 13:38:03.626885	2026-06-24
61	phase-1-5-demo-plumber	3	daily	46.59	65.69	6.40	2026-06-24 13:38:03.626885	2026-06-25
62	phase-1-5-demo-plumber	3	daily	47.07	66.55	6.50	2026-06-24 13:38:03.626885	2026-06-26
63	phase-1-5-demo-plumber	3	daily	47.55	67.41	6.60	2026-06-24 13:38:03.626885	2026-06-27
64	phase-1-5-demo-plumber	3	daily	48.03	68.28	6.70	2026-06-24 13:38:03.626885	2026-06-28
120	curated-demo-tn-hotel-la-badira-hammamet	48	current	46	45	\N	2026-06-29 15:07:52.143823	2026-06-29
123	curated-demo-fr-restaurant-septime-paris	51	current	70	71	\N	2026-06-29 15:07:52.15786	2026-06-29
124	curated-demo-tn-dental-clinic-sourire-sousse	52	current	77	50	\N	2026-06-29 15:07:52.283983	2026-06-29
125	curated-demo-fr-dental-clinic-saint-lazare-paris	53	current	78	72	\N	2026-06-29 15:07:52.283971	2026-06-29
128	curated-demo-be-real-estate-century21-brussels	56	current	51	55	\N	2026-06-29 15:08:14.258905	2026-06-29
131	curated-demo-fr-beauty-salon-dessange-paris	59	current	66	62	\N	2026-06-29 15:08:14.39427	2026-06-29
135	curated-demo-tn-car-repair-carthage-auto-ariana	63	current	66	48	\N	2026-06-29 15:08:30.902983	2026-06-29
65	phase-1-5-demo-plumber	3	daily	48.52	69.14	6.80	2026-06-24 13:38:03.626885	2026-06-29
66	phase-1-5-demo-plumber	3	daily	49.00	70.00	6.90	2026-06-24 13:38:03.626885	2026-06-30
1	phase-1-5-demo-agency	1	current	74.00	26.00	1.10	2026-06-24 10:16:01.541968	2026-06-24
2	phase-1-5-demo-agency	1	monthly	70.00	30.00	4.40	2026-06-24 10:16:01.541968	2026-06-24
67	phase-1-5-demo-agency	1	daily	60.00	30.00	6.00	2026-06-24 13:38:03.626885	2026-06-01
68	phase-1-5-demo-agency	1	daily	60.52	30.62	6.10	2026-06-24 13:38:03.626885	2026-06-02
69	phase-1-5-demo-agency	1	daily	61.03	31.24	6.20	2026-06-24 13:38:03.626885	2026-06-03
70	phase-1-5-demo-agency	1	daily	61.55	31.86	6.30	2026-06-24 13:38:03.626885	2026-06-04
71	phase-1-5-demo-agency	1	daily	62.07	32.48	6.40	2026-06-24 13:38:03.626885	2026-06-05
72	phase-1-5-demo-agency	1	daily	62.59	33.10	6.50	2026-06-24 13:38:03.626885	2026-06-06
73	phase-1-5-demo-agency	1	daily	63.10	33.72	6.60	2026-06-24 13:38:03.626885	2026-06-07
74	phase-1-5-demo-agency	1	daily	63.62	34.34	6.70	2026-06-24 13:38:03.626885	2026-06-08
75	phase-1-5-demo-agency	1	daily	64.14	34.97	6.80	2026-06-24 13:38:03.626885	2026-06-09
76	phase-1-5-demo-agency	1	daily	64.66	35.59	6.90	2026-06-24 13:38:03.626885	2026-06-10
77	phase-1-5-demo-agency	1	daily	65.17	36.21	7.00	2026-06-24 13:38:03.626885	2026-06-11
78	phase-1-5-demo-agency	1	daily	65.69	36.83	7.10	2026-06-24 13:38:03.626885	2026-06-12
79	phase-1-5-demo-agency	1	daily	66.21	37.45	7.20	2026-06-24 13:38:03.626885	2026-06-13
80	phase-1-5-demo-agency	1	daily	66.72	38.07	7.30	2026-06-24 13:38:03.626885	2026-06-14
81	phase-1-5-demo-agency	1	daily	67.24	38.69	7.40	2026-06-24 13:38:03.626885	2026-06-15
82	phase-1-5-demo-agency	1	daily	67.76	39.31	7.50	2026-06-24 13:38:03.626885	2026-06-16
83	phase-1-5-demo-agency	1	daily	68.28	39.93	7.60	2026-06-24 13:38:03.626885	2026-06-17
84	phase-1-5-demo-agency	1	daily	68.79	40.55	7.70	2026-06-24 13:38:03.626885	2026-06-18
85	phase-1-5-demo-agency	1	daily	69.31	41.17	7.80	2026-06-24 13:38:03.626885	2026-06-19
86	phase-1-5-demo-agency	1	daily	69.83	41.79	7.90	2026-06-24 13:38:03.626885	2026-06-20
87	phase-1-5-demo-agency	1	daily	70.34	42.41	8.00	2026-06-24 13:38:03.626885	2026-06-21
88	phase-1-5-demo-agency	1	daily	70.86	43.03	8.10	2026-06-24 13:38:03.626885	2026-06-22
\.


--
-- Data for Name: leads; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.leads (google_place_id, name, address, phone, website, rating, "userRatingsTotal", lat, lng, "searchQuery", state, "createdAt", "lastUpdated") FROM stdin;
phase-1-5-demo-bakery	Demo Bakery	1 Seed Street	\N	\N	4.2	18	36.8065	10.1815	phase-1.5-demo	RAW	2026-06-24 10:16:01.541968	2026-06-24 10:16:01.541968
phase-1-5-demo-agency	Demo Agency	3 Seed Street	\N	https://example.test/agency	\N	\N	36.8	10.19	phase-1.5-demo	RAW	2026-06-24 10:16:01.541968	2026-06-24 10:16:01.541968
curated-demo-tn-real-estate-mubawab-tunis	Mubawab Tunisie Immobilier	Immeuble Golden Towers, Centre Urbain Nord, Tunis, Tunisia	+216 70 029 240	https://www.mubawab.tn	4.1	239	36.8452	10.2019	real estate	RAW	2026-06-29 14:36:21.264157	2026-06-29 15:08:14.248784
phase-1-5-demo-plumber	Demo Plumber	2 Seed Street	+216 00 000 002	https://example.com	4.6	31	36.812	10.176	phase-1.5-demo	RAW	2026-06-24 10:16:01.541968	2026-06-24 10:16:01.541968
curated-demo-be-real-estate-century21-brussels	Century 21 Brussels South	Chaussee de Waterloo 715, 1180 Uccle, Belgium	+32 2 343 22 40	https://www.century21.be	4	118	50.8088	4.3642	real estate	RAW	2026-06-29 14:35:48.533556	2026-06-29 15:08:14.248784
curated-demo-tn-beauty-salon-nour-sfax	صالون نور - Salon Nour Beaute	Route de Gremda km 2, 3000 Sfax, Tunisia	+216 74 402 118	\N	4	58	34.7486	10.7553	beauty salon	RAW	2026-06-29 14:36:21.479826	2026-06-29 15:08:14.390057
curated-demo-tn-car-repair-carthage-auto-ariana	Garage Carthage Auto	Rue de l Industrie, 2080 Ariana, Tunisia	+216 71 706 219	\N	4.3	102	36.8611	10.1938	car repair	RAW	2026-06-29 14:36:33.111187	2026-06-29 15:08:30.897918
curated-demo-fr-car-repair-norauto-lyon	Norauto Lyon Bron	209 Avenue Franklin Roosevelt, 69500 Bron, France	+33 4 72 37 80 80	https://www.norauto.fr	4	684	45.7338	4.9132	car repair	RAW	2026-06-29 14:36:33.111187	2026-06-29 15:08:30.897918
curated-demo-fr-beauty-salon-dessange-paris	Dessange Paris Madeleine	4 Rue du Faubourg Saint-Honore, 75008 Paris, France	+33 1 42 65 08 05	https://www.dessange.com	4.3	221	48.8682	2.3222	beauty salon	RAW	2026-06-29 14:36:21.479826	2026-06-29 15:08:14.390057
curated-demo-tn-plumber-hydrotek-tunis	Hydrotek Plomberie Tunis	Avenue Hedi Nouira, 2037 Ariana, Tunisia	+216 71 702 944	\N	4.2	43	36.8625	10.1956	plumber	RAW	2026-06-29 14:36:21.30581	2026-06-29 15:08:14.396406
curated-demo-tn-dental-clinic-sourire-sousse	Clinique Dentaire Sourire du Sahel	Boulevard du 14 Janvier, 4039 Sousse, Tunisia	+216 73 822 410	https://www.doctolib.fr	4.8	127	35.8291	10.6407	dentist	RAW	2026-06-29 14:36:07.957158	2026-06-29 15:07:52.279796
curated-demo-be-plumber-facq-brussels	FACQ Brussels Plumbing Showroom	Rue de Birmingham 112, 1070 Brussels, Belgium	+32 2 558 29 11	https://www.facq.be	4.1	312	50.8434	4.3226	plumber	RAW	2026-06-29 14:36:21.30581	2026-06-29 15:08:14.396406
curated-demo-fr-dental-clinic-saint-lazare-paris	Centre Dentaire Saint-Lazare	12 Rue de Londres, 75009 Paris, France	+33 1 42 81 44 20	https://www.doctolib.fr	4.4	346	48.8765	2.3296	dentist	RAW	2026-06-29 14:36:07.957158	2026-06-29 15:07:52.279796
curated-demo-tn-digital-agency-kif-lac-tunis	Kif Digital Studio	Rue du Lac Malaren, Les Berges du Lac 1, Tunis, Tunisia	+216 70 145 880	https://www.tapptic.com	4.7	58	36.8383	10.2419	digital agency	RAW	2026-06-29 14:36:21.264157	2026-06-29 15:08:14.242881
curated-demo-be-digital-agency-tapptic-brussels	Tapptic Brussels	Avenue Louise 523, 1050 Brussels, Belgium	+32 2 318 44 72	https://www.tapptic.com	4.6	74	50.8162	4.3687	digital agency	RAW	2026-06-29 14:35:48.533556	2026-06-29 15:08:14.242881
curated-demo-tn-law-office-ferchiou-tunis	Ferchiou & Associes	Rue du Lac Lochness, Les Berges du Lac, Tunis, Tunisia	+216 71 965 620	https://www.ferchioulaw.com	4.5	31	36.8439	10.2673	law office	RAW	2026-06-29 14:36:33.161237	2026-06-29 15:08:30.896978
curated-demo-be-law-office-liedekerke-brussels	Liedekerke Brussels	Boulevard de l Empereur 3, 1000 Brussels, Belgium	+32 2 551 15 15	https://liedekerke.com	4.6	44	50.8458	4.3547	law office	RAW	2026-06-29 14:36:33.161237	2026-06-29 15:08:30.896978
curated-demo-tn-bakery-medina-tunis	مخبزة المدينة - Boulangerie Medina	18 Rue de Marseille, 1001 Tunis, Tunisia	+216 71 256 418	https://www.paul.fr	4.5	214	36.7992	10.1815	bakery	RAW	2026-06-29 14:35:48.532331	2026-06-29 15:06:53.634663
curated-demo-fr-bakery-poilane-paris	Poilane Saint-Germain	8 Rue du Cherche-Midi, 75006 Paris, France	+33 1 45 48 42 59	https://www.poilane.com	4.7	1420	48.8507	2.3268	bakery	RAW	2026-06-29 14:36:07.881612	2026-06-29 15:06:53.634663
curated-demo-tn-hotel-la-badira-hammamet	La Badira Hammamet	BP 437, 8050 Hammamet, Tunisia	+216 70 018 180	https://www.labadira.com	4.7	2610	36.4081	10.6482	hotel	RAW	2026-06-29 14:35:48.570533	2026-06-29 15:07:52.13838
curated-demo-fr-hotel-accor-paris-montparnasse	Hotel Mercure Paris Montparnasse Raspail	207 Boulevard Raspail, 75014 Paris, France	+33 1 43 20 62 94	https://www.accor.com	4.2	962	48.8404	2.3291	hotel	RAW	2026-06-29 14:36:07.92164	2026-06-29 15:07:52.13838
curated-demo-tn-restaurant-dar-sahel-sousse	Dar Sahel Restaurant	Avenue Hedi Chaker, 4000 Sousse, Tunisia	+216 73 224 680	\N	4.3	186	35.8256	10.6369	restaurant	RAW	2026-06-29 14:36:07.920106	2026-06-29 15:07:52.144972
curated-demo-fr-restaurant-septime-paris	Septime Paris	80 Rue de Charonne, 75011 Paris, France	+33 1 43 67 38 29	https://www.septime-charonne.fr	4.6	1384	48.8537	2.3816	restaurant	RAW	2026-06-29 14:36:07.920106	2026-06-29 15:07:52.144972
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1750766400000	CreateLeadIntelligenceTables1750766400000
2	1782259200000	CreateLeadAxisScores1782259200000
3	1782307200000	AddLeadScoreDate1782307200000
4	1782393600000	CreateScrapingTrackingTables1782393600000
\.


--
-- Data for Name: scraping_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scraping_jobs (id, lead_id, job_type, status, source, trigger, started_at, finished_at, duration_ms, error_message, created_at, updated_at) FROM stdin;
1	phase-1-5-demo-bakery	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	420	\N	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
2	phase-1-5-demo-bakery	SEO	SUCCESS	website	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	510	\N	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
3	phase-1-5-demo-bakery	SOCIAL	PARTIAL	facebook	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	650	Instagram profile unavailable in demo seed	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
4	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	440	\N	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
5	phase-1-5-demo-plumber	SEO	PARTIAL	website	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	590	Robots metadata missing in demo seed	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
6	phase-1-5-demo-plumber	SOCIAL	FAILED	facebook	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	320	Social profile lookup failed in demo seed	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
7	phase-1-5-demo-agency	FULL	SUCCESS	fastapi_scraper	initial_enrichment	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297	880	\N	2026-06-25 13:20:19.684297	2026-06-25 13:20:19.684297
9	phase-1-5-demo-plumber	WEBSITE	FAILED	website	manual	2026-06-28 20:00:02.464721	2026-06-28 20:00:02.776188	311	(psycopg.errors.NotNullViolation) null value in column "created_at" of relation "scraping_raw_results" violates not-null constraint\nDETAIL:  Failing row contains (8, 9, phase-1-5-demo-plumber, website, {"url": "https://example.com", "title": "Example Domain", "email..., RAW, phase-1-5-demo-plumber:WEBSITE:website:9, null).\n[SQL: INSERT INTO scraping_raw_results (job_id, lead_id, source, raw_json, normalized_status, dedupe_key, created_at) VALUES (%(job_id)s::INTEGER, %(lead_id)s::VARCHAR, %(source)s::VARCHAR, %(raw_json)s::JSONB, %(normalized_status)s::VARCHAR, %(dedupe_key)s::VARCHAR, %(created_at)s::TIMESTAMP WITHOUT TIME ZONE) RETURNING scraping_raw_results.id]\n[parameters: {'job_id': 9, 'lead_id': 'phase-1-5-demo-plumber', 'source': 'website', 'raw_json': Jsonb({'success': True, 'url': 'https://e ... (227 chars)), 'normalized_status': 'RAW', 'dedupe_key': 'phase-1-5-demo-plumber:WEBSITE:website:9', 'created_at': None}]\n(Background on this error at: https://sqlalche.me/e/20/gkpj)	2026-06-28 19:59:28.311965	2026-06-28 20:00:02.776188
11	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 08:54:20.420307	2026-06-29 08:54:20.711637	291	\N	2026-06-29 08:54:19.032048	2026-06-29 08:54:20.711637
12	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 09:13:31.484578	2026-06-29 09:13:31.723341	238	\N	2026-06-29 09:12:49.331535	2026-06-29 09:13:31.723341
38	curated-demo-tn-bakery-medina-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:11.1522	2026-06-29 14:37:12.24969	1097	\N	2026-06-29 14:35:48.560646	2026-06-29 14:37:12.24969
39	curated-demo-be-digital-agency-tapptic-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:12.255601	2026-06-29 14:37:15.827842	3572	\N	2026-06-29 14:35:48.561626	2026-06-29 14:37:15.827842
40	curated-demo-be-real-estate-century21-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:15.8369	2026-06-29 14:37:17.990782	2153	\N	2026-06-29 14:35:48.57271	2026-06-29 14:37:17.990782
41	curated-demo-tn-hotel-la-badira-hammamet	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:17.996773	2026-06-29 14:37:19.19128	1194	\N	2026-06-29 14:35:48.578581	2026-06-29 14:37:19.19128
42	curated-demo-fr-bakery-poilane-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:19.20408	2026-06-29 14:37:20.498876	1294	\N	2026-06-29 14:36:07.91612	2026-06-29 14:37:20.498876
19	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 10:09:59.377753	2026-06-29 10:09:59.635176	257	\N	2026-06-29 10:08:25.493306	2026-06-29 10:09:59.635176
43	curated-demo-fr-restaurant-septime-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:29.5549	2026-06-29 14:37:30.441778	886	\N	2026-06-29 14:36:07.931538	2026-06-29 14:37:30.441778
20	phase-1-5-demo-plumber	SEO	FAILED	website	manual	2026-06-29 10:10:01.655298	2026-06-29 10:10:01.669651	14	SEO scraper is not implemented in this milestone	2026-06-29 10:08:25.493306	2026-06-29 10:10:01.669651
21	phase-1-5-demo-plumber	CONTACTS	FAILED	website	manual	2026-06-29 10:10:03.682645	2026-06-29 10:10:03.689554	6	CONTACTS scraper is not implemented in this milestone	2026-06-29 10:08:25.493306	2026-06-29 10:10:03.689554
44	curated-demo-fr-hotel-accor-paris-montparnasse	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:30.461668	2026-06-29 14:37:32.093681	1632	\N	2026-06-29 14:36:07.931655	2026-06-29 14:37:32.093681
22	phase-1-5-demo-plumber	SOCIAL	FAILED	fastapi_scraper	manual	2026-06-29 10:10:05.701085	2026-06-29 10:10:05.710377	9	SOCIAL scraper is not implemented in this milestone	2026-06-29 10:08:25.493306	2026-06-29 10:10:05.710377
45	curated-demo-tn-dental-clinic-sourire-sousse	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:32.098778	2026-06-29 14:37:38.419955	6321	\N	2026-06-29 14:36:07.980339	2026-06-29 14:37:38.419955
23	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	codex_validation	2026-06-29 10:24:55.928267	2026-06-29 10:24:56.450645	522	\N	2026-06-29 10:24:46.029254	2026-06-29 10:24:56.450645
46	curated-demo-fr-dental-clinic-saint-lazare-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:38.426943	2026-06-29 14:37:43.181109	4754	\N	2026-06-29 14:36:07.980689	2026-06-29 14:37:43.181109
47	curated-demo-tn-digital-agency-kif-lac-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:43.18773	2026-06-29 14:37:45.788758	2601	\N	2026-06-29 14:36:21.274421	2026-06-29 14:37:45.788758
48	curated-demo-tn-real-estate-mubawab-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:57.896894	2026-06-29 14:37:59.192658	1295	\N	2026-06-29 14:36:21.284178	2026-06-29 14:37:59.192658
49	curated-demo-be-plumber-facq-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:37:59.205535	2026-06-29 14:38:01.512227	2306	\N	2026-06-29 14:36:21.358694	2026-06-29 14:38:01.512227
25	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 10:50:38.963526	2026-06-29 10:50:39.638023	674	\N	2026-06-29 10:50:05.002852	2026-06-29 10:50:39.638023
26	phase-1-5-demo-plumber	SEO	FAILED	website	manual	2026-06-29 10:50:41.665531	2026-06-29 10:50:41.679579	14	SEO scraper is not implemented in this milestone	2026-06-29 10:50:05.002852	2026-06-29 10:50:41.679579
50	curated-demo-fr-beauty-salon-dessange-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:38:01.518697	2026-06-29 14:38:03.70358	2184	\N	2026-06-29 14:36:21.513295	2026-06-29 14:38:03.70358
27	phase-1-5-demo-plumber	CONTACTS	FAILED	website	manual	2026-06-29 10:50:43.689349	2026-06-29 10:50:43.693863	4	CONTACTS scraper is not implemented in this milestone	2026-06-29 10:50:05.002852	2026-06-29 10:50:43.693863
28	phase-1-5-demo-plumber	SOCIAL	FAILED	fastapi_scraper	manual	2026-06-29 10:52:32.658807	2026-06-29 10:52:32.678946	20	SOCIAL scraper is not implemented in this milestone	2026-06-29 10:50:05.002852	2026-06-29 10:52:32.678946
51	curated-demo-fr-car-repair-norauto-lyon	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:38:03.713084	2026-06-29 14:38:04.35765	644	\N	2026-06-29 14:36:33.138716	2026-06-29 14:38:04.35765
52	curated-demo-be-law-office-liedekerke-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:38:04.363038	2026-06-29 14:38:07.539164	3176	\N	2026-06-29 14:36:33.167923	2026-06-29 14:38:07.539164
53	curated-demo-tn-law-office-ferchiou-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 14:38:18.892945	2026-06-29 14:38:27.678389	8785	\N	2026-06-29 14:36:33.16794	2026-06-29 14:38:27.678389
32	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 13:36:49.941364	2026-06-29 13:36:50.626265	684	\N	2026-06-29 13:30:56.024896	2026-06-29 13:36:50.626265
56	curated-demo-fr-bakery-poilane-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:09:51.077521	2026-06-29 15:09:52.692963	1615	\N	2026-06-29 15:03:01.721663	2026-06-29 15:09:52.692963
33	phase-1-5-demo-plumber	WEBSITE	SUCCESS	website	manual	2026-06-29 14:07:47.503249	2026-06-29 14:07:48.183436	680	\N	2026-06-29 13:30:56.029649	2026-06-29 14:07:48.183436
57	curated-demo-tn-hotel-la-badira-hammamet	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:09:52.741541	2026-06-29 15:09:54.547688	1806	\N	2026-06-29 15:03:01.792326	2026-06-29 15:09:54.547688
34	phase-1-5-demo-plumber	SEO	FAILED	website	manual	2026-06-29 14:07:48.19233	2026-06-29 14:07:48.200581	8	SEO scraper is not implemented in this milestone	2026-06-29 13:30:56.029649	2026-06-29 14:07:48.200581
58	curated-demo-fr-hotel-accor-paris-montparnasse	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:09:54.55228	2026-06-29 15:09:56.206612	1654	\N	2026-06-29 15:03:01.792351	2026-06-29 15:09:56.206612
59	curated-demo-tn-dental-clinic-sourire-sousse	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:09.473636	2026-06-29 15:10:15.915975	6442	\N	2026-06-29 15:03:01.793894	2026-06-29 15:10:15.915975
69	curated-demo-tn-law-office-ferchiou-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:11:10.085908	2026-06-29 15:11:17.263238	7177	\N	2026-06-29 15:03:29.919511	2026-06-29 15:11:17.263238
55	curated-demo-fr-restaurant-septime-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:09:48.533911	2026-06-29 15:09:49.957023	1423	\N	2026-06-29 15:03:01.720437	2026-06-29 15:09:49.957023
54	curated-demo-tn-bakery-medina-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:09:49.972614	2026-06-29 15:09:51.068766	1096	\N	2026-06-29 15:03:01.721636	2026-06-29 15:09:51.068766
60	curated-demo-fr-dental-clinic-saint-lazare-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:15.925909	2026-06-29 15:10:22.114602	6188	\N	2026-06-29 15:03:01.793918	2026-06-29 15:10:22.114602
62	curated-demo-tn-digital-agency-kif-lac-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:22.120406	2026-06-29 15:10:26.888509	4768	\N	2026-06-29 15:03:18.881842	2026-06-29 15:10:26.888509
61	curated-demo-tn-real-estate-mubawab-tunis	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:26.895731	2026-06-29 15:10:28.212836	1317	\N	2026-06-29 15:03:18.881893	2026-06-29 15:10:28.212836
63	curated-demo-be-digital-agency-tapptic-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:28.217596	2026-06-29 15:10:30.671475	2453	\N	2026-06-29 15:03:18.881931	2026-06-29 15:10:30.671475
64	curated-demo-be-real-estate-century21-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:44.691381	2026-06-29 15:10:47.606726	2915	\N	2026-06-29 15:03:18.881955	2026-06-29 15:10:47.606726
65	curated-demo-be-plumber-facq-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:47.613979	2026-06-29 15:10:49.255941	1641	\N	2026-06-29 15:03:18.953504	2026-06-29 15:10:49.255941
66	curated-demo-fr-beauty-salon-dessange-paris	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:49.263337	2026-06-29 15:10:52.058605	2795	\N	2026-06-29 15:03:18.955086	2026-06-29 15:10:52.058605
67	curated-demo-fr-car-repair-norauto-lyon	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:52.064774	2026-06-29 15:10:52.689907	625	\N	2026-06-29 15:03:29.887938	2026-06-29 15:10:52.689907
68	curated-demo-be-law-office-liedekerke-brussels	WEBSITE	SUCCESS	website	initial_enrichment	2026-06-29 15:10:52.705113	2026-06-29 15:10:55.725062	3019	\N	2026-06-29 15:03:29.919506	2026-06-29 15:10:55.725062
\.


--
-- Data for Name: scraping_raw_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scraping_raw_results (id, job_id, lead_id, source, raw_json, normalized_status, dedupe_key, created_at) FROM stdin;
1	1	phase-1-5-demo-bakery	website	{"url": "https://example.test/demo-1", "notes": "development seed only", "title": "Demo title 1", "source": "website"}	RAW	phase-1-5-demo-bakery:WEBSITE:website:phase-1.5	2026-06-25 13:20:19.684297
2	2	phase-1-5-demo-bakery	website	{"url": "https://example.test/demo-1/seo", "notes": "development seed only", "title": "Demo title 1 SEO", "source": "website"}	RAW	phase-1-5-demo-bakery:SEO:website:phase-1.5	2026-06-25 13:20:19.684297
3	3	phase-1-5-demo-bakery	facebook	{"url": "https://facebook.com/example-bakery", "notes": "development seed only", "title": "Demo Bakery social profile", "source": "facebook"}	RAW	phase-1-5-demo-bakery:SOCIAL:facebook:phase-1.5	2026-06-25 13:20:19.684297
4	4	phase-1-5-demo-plumber	website	{"url": "https://example.test/demo-2", "notes": "development seed only", "title": "Demo title 2", "source": "website"}	RAW	phase-1-5-demo-plumber:WEBSITE:website:phase-1.5	2026-06-25 13:20:19.684297
5	5	phase-1-5-demo-plumber	website	{"url": "https://example.test/demo-2/seo", "notes": "development seed only", "title": "Demo title 2 SEO", "source": "website"}	RAW	phase-1-5-demo-plumber:SEO:website:phase-1.5	2026-06-25 13:20:19.684297
6	6	phase-1-5-demo-plumber	facebook	{"url": "https://facebook.com/example-plumber", "notes": "development seed only", "title": "Demo Plumber social profile", "source": "facebook"}	RAW	phase-1-5-demo-plumber:SOCIAL:facebook:phase-1.5	2026-06-25 13:20:19.684297
7	7	phase-1-5-demo-agency	fastapi_scraper	{"url": "https://example.test/demo-3", "notes": "development seed only", "title": "Demo title 3", "source": "fastapi_scraper"}	RAW	phase-1-5-demo-agency:FULL:fastapi_scraper:phase-1.5	2026-06-25 13:20:19.684297
10	11	phase-1-5-demo-plumber	website	{"url": "https://example.com", "title": "Example Domain", "emails": [], "phones": [], "success": true, "final_url": "https://example.com", "status_code": 200, "social_links": {}, "error_message": null, "meta_description": null}	RAW	phase-1-5-demo-plumber:WEBSITE:website:11	2026-06-29 08:54:20.433476
11	12	phase-1-5-demo-plumber	website	{"url": "https://example.com", "title": "Example Domain", "emails": [], "phones": [], "success": true, "final_url": "https://example.com", "status_code": 200, "social_links": {}, "error_message": null, "meta_description": null}	RAW	phase-1-5-demo-plumber:WEBSITE:website:12	2026-06-29 09:13:31.489529
58	69	curated-demo-tn-law-office-ferchiou-tunis	website	{"seo": {"noindex": false, "h1_texts": ["One of the leading commercial law firms in Tunisia", "With more than 30 years of experience", "The Firm has been consistently involved in Tunisia's high profile projects", "All aspects of Business and Commercial law", "High level negotiating skills", "ABOUT FERCHIOU LAW", "AREAS OF PRACTICE", "OUR STRATEGIC ADVANTAGE", "Victories", "YOUR INITIAL CONSULTATION"], "h2_texts": ["Let’s Get Started on Your Confidential Consultation", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR Alternative Dispute Resolution all forms of mediation", "ADR Alternative Dispute Resolution all forms of mediation", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT"], "nofollow": false, "robots_txt": true, "robots_meta": "noodp, noydir", "title_exists": true, "title_length": 19, "images_with_alt": 15, "schema_org_types": [], "canonical_present": true, "images_without_alt": 6, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 36}, "url": "https://www.ferchioulaw.com", "hsts": true, "https": true, "title": "Ferchiou & Associés", "emails": ["contact@ferchioulaw.com"], "phones": ["+2167 1120 500", "+2167 1350 028"], "server": "openresty/1.25.3.1", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/start/join", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.ferchioulaw.com/wp-content/themes/paperstreet/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": ["contact@ferchioulaw.com"], "phones": ["+2167 1120 500", "+2167 1350 028"], "tel_links": ["+2167 1120 500"], "mailto_links": ["contact@ferchioulaw.com"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.ferchioulaw.com", "https://www.ferchioulaw.com/lets-connect.php", "https://www.ferchioulaw.com/practices/child-support/index.html", "https://www.ferchioulaw.com/practices/spousal-support/index.html"], "contact_form_count": 1, "newsletter_form_detected": false}, "h1_count": 10, "h1_texts": ["One of the leading commercial law firms in Tunisia", "With more than 30 years of experience", "The Firm has been consistently involved in Tunisia's high profile projects", "All aspects of Business and Commercial law", "High level negotiating skills", "ABOUT FERCHIOU LAW", "AREAS OF PRACTICE", "OUR STRATEGIC ADVANTAGE", "Victories", "YOUR INITIAL CONSULTATION"], "h2_count": 20, "h2_texts": ["Let’s Get Started on Your Confidential Consultation", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR Alternative Dispute Resolution all forms of mediation", "ADR Alternative Dispute Resolution all forms of mediation", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT"], "language": null, "nofollow": false, "final_url": "https://www.ferchioulaw.com", "logo_image": "https://www.ferchioulaw.com/image/logo2.png", "open_graph": {"og:url": "https://www.ferchioulaw.com/", "og:image": "https://www.ferchioulaw.com/image/open-graph-images/opengraph.png", "og:title": "Ferchiou & Associés", "og:description": null}, "forms_count": 3, "robots_meta": "noodp, noydir", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 21, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/start/join"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 19, "twitter_card": {"twitter:card": "summary", "twitter:image": "https://www.ferchioulaw.com/image/open-graph-images/opengraph.png", "twitter:title": "Ferchiou & Associés", "twitter:description": "Leading Business Law Firm In Tunisia."}, "canonical_url": "https://www.ferchioulaw.com/", "error_message": null, "footer_exists": true, "meta_keywords": "ferchiou, ferchiou law firm, ferchiou & associés, business law, droit, droit international, droit des affaires, avocat, avocats, cabinet d'avocats, tunisie, tunisia, conseil, entreprises, corporate, contrats, expertise, real estate, bank et finance, banking, finance, economic law, investissement, investment, judiciaire, tax, taxation, fiscal, international, droit social, droit du travail, droit boursier, ADR, labor and employment, fiscalité, droit public, droit international, droit fiscal, bourse, property, intellectuelle, droit de la concurrence, infrastructure, reglementation, environnement, environment, energie, energy, immobilier, litiges,", "redirect_count": 0, "robots_txt_url": "https://www.ferchioulaw.com/robots.txt", "images_with_alt": 15, "sitemap_xml_url": "https://www.ferchioulaw.com/sitemap.xml", "meta_description": "Leading Business Law Firm In Tunisia", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 6, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 6, "internal_links_count": 19, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 14, "meta_description_exists": true, "meta_description_length": 36}	NORMALIZED	curated-demo-tn-law-office-ferchiou-tunis:WEBSITE:website:69	2026-06-29 15:11:10.092738
15	19	phase-1-5-demo-plumber	website	{"url": "https://example.com", "hsts": false, "https": true, "title": "Example Domain", "emails": [], "phones": [], "server": "cloudflare", "favicon": "data:,", "success": true, "language": "en", "final_url": "https://example.com", "logo_image": null, "status_code": 200, "content_type": "text/html", "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "meta_description": null, "about_page_exists": false, "contact_page_exists": false, "navigation_links_count": 0}	NORMALIZED	phase-1-5-demo-plumber:WEBSITE:website:19	2026-06-29 10:09:59.384291
16	23	phase-1-5-demo-plumber	website	{"url": "https://example.com", "hsts": false, "https": true, "title": "Example Domain", "emails": [], "phones": [], "server": "cloudflare", "favicon": "data:,", "success": true, "h1_count": 1, "h2_count": 0, "language": "en", "final_url": "https://example.com", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "status_code": 200, "content_type": "text/html", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://example.com/robots.txt", "sitemap_xml_url": "https://example.com/sitemap.xml", "meta_description": null, "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "contact_page_exists": false, "external_links_count": 1, "internal_links_count": 0, "robots_txt_available": false, "sitemap_xml_available": false, "navigation_links_count": 0}	NORMALIZED	phase-1-5-demo-plumber:WEBSITE:website:23	2026-06-29 10:24:55.937291
18	25	phase-1-5-demo-plumber	website	{"seo": {"noindex": false, "h1_texts": ["Example Domain"], "h2_texts": [], "nofollow": false, "robots_txt": false, "robots_meta": null, "title_exists": true, "title_length": 14, "images_with_alt": 0, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": false, "meta_description_length": 0}, "url": "https://example.com", "hsts": false, "https": true, "title": "Example Domain", "emails": [], "phones": [], "server": "cloudflare", "favicon": "data:,", "noindex": false, "success": true, "h1_count": 1, "h1_texts": ["Example Domain"], "h2_count": 0, "h2_texts": [], "language": "en", "nofollow": false, "final_url": "https://example.com", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 14, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://example.com/robots.txt", "images_with_alt": 0, "sitemap_xml_url": "https://example.com/sitemap.xml", "meta_description": null, "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 1, "internal_links_count": 0, "meta_keywords_exists": false, "robots_txt_available": false, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": false, "meta_description_length": 0}	NORMALIZED	phase-1-5-demo-plumber:WEBSITE:website:25	2026-06-29 10:50:38.971042
22	32	phase-1-5-demo-plumber	website	{"seo": {"noindex": false, "h1_texts": ["Example Domain"], "h2_texts": [], "nofollow": false, "robots_txt": false, "robots_meta": null, "title_exists": true, "title_length": 14, "images_with_alt": 0, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": false, "meta_description_length": 0}, "url": "https://example.com", "hsts": false, "https": true, "title": "Example Domain", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "data:,", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Example Domain"], "h2_count": 0, "h2_texts": [], "language": "en", "nofollow": false, "final_url": "https://example.com", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 14, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://example.com/robots.txt", "images_with_alt": 0, "sitemap_xml_url": "https://example.com/sitemap.xml", "meta_description": null, "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 1, "internal_links_count": 0, "meta_keywords_exists": false, "robots_txt_available": false, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": false, "meta_description_length": 0}	NORMALIZED	phase-1-5-demo-plumber:WEBSITE:website:32	2026-06-29 13:36:49.947545
23	33	phase-1-5-demo-plumber	website	{"seo": {"noindex": false, "h1_texts": ["Example Domain"], "h2_texts": [], "nofollow": false, "robots_txt": false, "robots_meta": null, "title_exists": true, "title_length": 14, "images_with_alt": 0, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": false, "meta_description_length": 0}, "url": "https://example.com", "hsts": false, "https": true, "title": "Example Domain", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "data:,", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Example Domain"], "h2_count": 0, "h2_texts": [], "language": "en", "nofollow": false, "final_url": "https://example.com", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 14, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://example.com/robots.txt", "images_with_alt": 0, "sitemap_xml_url": "https://example.com/sitemap.xml", "meta_description": null, "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 1, "internal_links_count": 0, "meta_keywords_exists": false, "robots_txt_available": false, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": false, "meta_description_length": 0}	NORMALIZED	phase-1-5-demo-plumber:WEBSITE:website:33	2026-06-29 14:07:47.515928
27	38	curated-demo-tn-bakery-medina-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Pour passer une commande merci de renseigner votre code postal", "Services disponibles", "Adresse et horaires", "En savoir plus", "Les magasins les plus proches de chez vous", "Adresse et horaires", "PAUL sur un plateau !", "PAUL réélu Marque Préférée des Français©", "Devenir Franchisé PAUL"], "nofollow": false, "robots_txt": true, "robots_meta": "INDEX,FOLLOW", "title_exists": true, "title_length": 36, "images_with_alt": 6, "schema_org_types": [], "canonical_present": true, "images_without_alt": 23, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 151}, "url": "https://www.paul.fr", "hsts": false, "https": true, "title": "PAUL : Maison de qualité depuis 1889", "emails": [], "phones": [], "server": null, "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/PAULFranceOfficiel", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/boulangeries-paul", "detected": true}, "instagram": {"url": "https://www.instagram.com/paulfranceofficiel", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.paul.fr/media/favicon/stores/1/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": true}, "h1_count": 0, "h1_texts": [], "h2_count": 9, "h2_texts": ["Pour passer une commande merci de renseigner votre code postal", "Services disponibles", "Adresse et horaires", "En savoir plus", "Les magasins les plus proches de chez vous", "Adresse et horaires", "PAUL sur un plateau !", "PAUL réélu Marque Préférée des Français©", "Devenir Franchisé PAUL"], "language": "fr", "nofollow": false, "final_url": "https://www.paul.fr", "logo_image": "https://www.paul.fr/media/logo/stores/1/MicrosoftTeams-image_24_.png", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 7, "robots_meta": "INDEX,FOLLOW", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 29, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/PAULFranceOfficiel"], "linkedin": ["https://www.linkedin.com/company/boulangeries-paul"], "instagram": ["https://www.instagram.com/paulfranceofficiel"], "x_twitter": []}, "title_exists": true, "title_length": 36, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://www.paul.fr/", "error_message": null, "footer_exists": true, "meta_keywords": "Boulangeries PAUL France", "redirect_count": 0, "robots_txt_url": "https://www.paul.fr/robots.txt", "images_with_alt": 6, "sitemap_xml_url": "https://www.paul.fr/sitemap.xml", "meta_description": "Vous pouvez maintenant commander et réserver votre repas, votre gâteau en ligne sur paul.fr . ✓ Voir les établissements éligibles au click and collect.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 23, "open_graph_present": false, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 5, "internal_links_count": 69, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 9, "meta_description_exists": true, "meta_description_length": 151}	NORMALIZED	curated-demo-tn-bakery-medina-tunis:WEBSITE:website:38	2026-06-29 14:37:11.162542
28	39	curated-demo-be-digital-agency-tapptic-brussels	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "title_exists": true, "title_length": 40, "images_with_alt": 62, "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 263}, "url": "https://www.tapptic.com", "hsts": true, "https": true, "title": "Tapptic - Intelligent digital interfaces", "emails": [], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/company/tapptic", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon-32x32.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://tapptic.com/contact-us/", "https://www.tapptic.com/contact-us", "https://www.tapptic.com/contact-us/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 31, "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "language": "en-US", "nofollow": false, "final_url": "https://www.tapptic.com", "logo_image": null, "open_graph": {"og:url": "https://www.tapptic.com/", "og:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "og:title": "Tapptic - Intelligent digital interfaces", "og:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "forms_count": 0, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 98, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/company/tapptic"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 40, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "twitter:title": "Tapptic - Intelligent digital interfaces", "twitter:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "canonical_url": "https://www.tapptic.com/", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.tapptic.com/robots.txt", "images_with_alt": 62, "sitemap_xml_url": "https://www.tapptic.com/feed/", "meta_description": "Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.", "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 18, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 6, "meta_description_exists": true, "meta_description_length": 263}	NORMALIZED	curated-demo-be-digital-agency-tapptic-brussels:WEBSITE:website:39	2026-06-29 14:37:12.257829
29	40	curated-demo-be-real-estate-century21-brussels	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aarschot", "Anderlecht", "Antwerpen", "Brussels", "Charleroi", "Ciney", "Gent", "Halle", "Koksijde", "Kortrijk", "Leuven", "Luik", "Mechelen", "Middelkerke", "Bergen", "Namen", "Nieuwpoort", "Schaarbeek", "Zinnik", "Doornik"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 62, "images_with_alt": 2, "schema_org_types": [], "canonical_present": true, "images_without_alt": 115, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 109}, "url": "https://www.century21.be", "hsts": false, "https": true, "title": "Nummer 1 netwerk van vastgoed makelaars in België en Luxemburg", "emails": [], "phones": [], "server": "AmazonS3", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/Century21Benelux", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/century21benelux", "detected": true}, "instagram": {"url": "https://www.instagram.com/century21_bnl", "detected": true}, "x_twitter": {"url": "https://twitter.com/Century21_bnl", "detected": true}}, "favicon": "https://www.century21.be/favicon-32x32.png?v=abba4c6b216924630502358f2136b5ea", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.century21.be/nl/contacteer-ons"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 20, "h2_texts": ["Aarschot", "Anderlecht", "Antwerpen", "Brussels", "Charleroi", "Ciney", "Gent", "Halle", "Koksijde", "Kortrijk", "Leuven", "Luik", "Mechelen", "Middelkerke", "Bergen", "Namen", "Nieuwpoort", "Schaarbeek", "Zinnik", "Doornik"], "language": "nl", "nofollow": false, "final_url": "https://www.century21.be/nl", "logo_image": null, "open_graph": {"og:url": "https://www.century21.be/nl", "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html", "images_count": 117, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/Century21Benelux"], "linkedin": ["https://www.linkedin.com/company/century21benelux"], "instagram": ["https://www.instagram.com/century21_bnl"], "x_twitter": ["https://twitter.com/Century21_bnl"]}, "title_exists": true, "title_length": 62, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://www.century21.be/nl", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://www.century21.be/robots.txt", "images_with_alt": 2, "sitemap_xml_url": "https://www.century21.be/sitemap/all-pages/sitemap-index.xml", "meta_description": "Het leidende netwerk van vastgoed makelaars in België . Ontdek onze diensten en zoek een kantoor in je buurt.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 115, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 7, "internal_links_count": 85, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 5, "meta_description_exists": true, "meta_description_length": 109}	NORMALIZED	curated-demo-be-real-estate-century21-brussels:WEBSITE:website:40	2026-06-29 14:37:15.840263
30	41	curated-demo-tn-hotel-la-badira-hammamet	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Concept", "Suites", "Gastronomie", "Evénements", "Découverte", "Adresse :", "téléphone :", "Whatsapp :", "e-mail :"], "nofollow": false, "robots_txt": true, "robots_meta": "max-image-preview:large", "title_exists": true, "title_length": 19, "images_with_alt": 28, "schema_org_types": ["BreadcrumbList", "ListItem", "Organization", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 28, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 310}, "url": "https://www.labadira.com", "hsts": false, "https": true, "title": "La badira - Accueil", "emails": ["contact@labadira.com"], "phones": ["2167 0018 180", "2169 4866 672"], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/labadira", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/labadira", "detected": true}, "instagram": {"url": "https://www.instagram.com/la_badira", "detected": true}, "x_twitter": {"url": "https://twitter.com/labadira", "detected": true}}, "favicon": "https://www.labadira.com/wp-content/themes/badira/images/favicon.png", "noindex": false, "success": true, "contacts": {"emails": ["contact@labadira.com"], "phones": ["2167 0018 180", "2169 4866 672"], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.labadira.com/contact/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 9, "h2_texts": ["Concept", "Suites", "Gastronomie", "Evénements", "Découverte", "Adresse :", "téléphone :", "Whatsapp :", "e-mail :"], "language": "fr-FR", "nofollow": false, "final_url": "https://www.labadira.com", "logo_image": "https://www.labadira.com/wp-content/themes/badira/images/logo-badira-10-w.png.webp", "open_graph": {"og:url": "https://www.labadira.com/", "og:image": "https://www.labadira.com/wp-content/uploads/2020/06/slider1.jpg", "og:title": "Hôtel 5 étoiles - Membre de Leading Hotels of the World", "og:description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel."}, "forms_count": 2, "robots_meta": "max-image-preview:large", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 56, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/labadira"], "linkedin": ["https://www.linkedin.com/company/labadira"], "instagram": ["https://www.instagram.com/la_badira"], "x_twitter": ["https://twitter.com/labadira"]}, "title_exists": true, "title_length": 19, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.labadira.com/wp-content/uploads/2020/06/slider1.jpg", "twitter:title": "Hôtel 5 étoiles - Membre de Leading Hotels of the World", "twitter:description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel."}, "canonical_url": "https://www.labadira.com/", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.labadira.com/robots.txt", "images_with_alt": 28, "sitemap_xml_url": "https://www.labadira.com/feed/", "meta_description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel.", "schema_org_types": ["BreadcrumbList", "ListItem", "Organization", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 28, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 10, "internal_links_count": 22, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 310}	NORMALIZED	curated-demo-tn-hotel-la-badira-hammamet:WEBSITE:website:41	2026-06-29 14:37:17.998976
31	42	curated-demo-fr-bakery-poilane-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": [], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 62, "images_with_alt": 34, "schema_org_types": ["Organization", "SearchAction", "WebSite"], "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 172}, "url": "https://www.poilane.com", "hsts": true, "https": true, "title": "Boulangerie artisanale de pain au levain Paris\\n    \\n – Poilâne", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": "https://www.tiktok.com/@poilane", "detected": true}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/painpoilane", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/s.a-poilane/mycompany", "detected": true}, "instagram": {"url": "https://www.instagram.com/poilane", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.poilane.com/cdn/shop/files/favicon-Poilane-32x32_32x32.png?v=1654504559", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.poilane.com/pages/contact"], "contact_form_count": 0, "newsletter_form_detected": true}, "h1_count": 0, "h1_texts": [], "h2_count": 0, "h2_texts": [], "language": "fr", "nofollow": false, "final_url": "https://www.poilane.com", "logo_image": null, "open_graph": {"og:url": "https://www.poilane.com/", "og:image": null, "og:title": "Boulangerie artisanale de pain au levain Paris", "og:description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous."}, "forms_count": 4, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 34, "social_links": {"tiktok": ["https://www.tiktok.com/@poilane"], "youtube": [], "facebook": ["https://www.facebook.com/painpoilane"], "linkedin": ["https://www.linkedin.com/company/s.a-poilane/mycompany"], "instagram": ["https://www.instagram.com/poilane"], "x_twitter": []}, "title_exists": true, "title_length": 62, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": null, "twitter:title": "Boulangerie artisanale de pain au levain Paris", "twitter:description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous."}, "canonical_url": "https://www.poilane.com/", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.poilane.com/robots.txt", "images_with_alt": 34, "sitemap_xml_url": "https://www.poilane.com/sitemap.xml", "meta_description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous.", "schema_org_types": ["Organization", "SearchAction", "WebSite"], "technology_hints": {"wix": false, "shopify": true, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 17, "internal_links_count": 66, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 48, "meta_description_exists": true, "meta_description_length": 172}	NORMALIZED	curated-demo-fr-bakery-poilane-paris:WEBSITE:website:42	2026-06-29 14:37:19.208568
40	51	curated-demo-fr-car-repair-norauto-lyon	website	{"seo": {"noindex": true, "h1_texts": [], "h2_texts": [], "nofollow": true, "robots_txt": false, "robots_meta": "noindex,nofollow", "title_exists": true, "title_length": 16, "images_with_alt": 0, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": false, "meta_description_length": 0}, "url": "https://www.norauto.fr", "hsts": false, "https": true, "title": "Just a moment...", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": null, "noindex": true, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 0, "h2_texts": [], "language": "en-US", "nofollow": true, "final_url": "https://www.norauto.fr", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": "noindex,nofollow", "status_code": 403, "content_type": "text/html; charset=UTF-8", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 16, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.norauto.fr/robots.txt", "images_with_alt": 0, "sitemap_xml_url": "https://www.norauto.fr/sitemap.xml", "meta_description": null, "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 0, "internal_links_count": 0, "meta_keywords_exists": false, "robots_txt_available": false, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": false, "meta_description_length": 0}	NORMALIZED	curated-demo-fr-car-repair-norauto-lyon:WEBSITE:website:51	2026-06-29 14:38:03.716408
41	52	curated-demo-be-law-office-liedekerke-brussels	website	{"seo": {"noindex": false, "h1_texts": ["Solid International Service Strong local expertise"], "h2_texts": ["Latest news", "Liedekerke advises Aukera Energy on the project financing of Volt, a 170 MW / 340 MWh BESS project", "Liedekerke attends EELA 2026, 4-6 June 2026 in Oslo", "ESG Enforcement & Litigation in Europe: Liedekerke Contributes to Lexology Panoramic Next 2026", "Insights", "Independence", "Legal excellence", "Pragmatic solutions", "Our Values", "Liedekerke", "Get in touch", "Useful links", "Stay informed"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 64, "images_with_alt": 18, "schema_org_types": ["Organization", "WebSite"], "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 140}, "url": "https://liedekerke.com", "hsts": false, "https": true, "title": "Liedekerke - Solid International Service Capability | Liedekerke", "emails": ["info@liedekerke.com"], "phones": ["+3225 5115 15"], "server": null, "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCyld0vG4etibMd8iSP4EoyQ/videos", "detected": true}, "facebook": {"url": "https://www.facebook.com/LWWKLAW", "detected": true}, "linkedin": {"url": "https://be.linkedin.com/company/liedekerke-wolters-waelbroeck-kirkpatrick", "detected": true}, "instagram": {"url": "https://www.instagram.com/liedekerkelaw", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://liedekerke.com/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": ["info@liedekerke.com"], "phones": ["+3225 5115 15"], "tel_links": ["+3225 5115 15"], "mailto_links": ["info@liedekerke.com"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://liedekerke.com/en/contact"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Solid International Service Strong local expertise"], "h2_count": 13, "h2_texts": ["Latest news", "Liedekerke advises Aukera Energy on the project financing of Volt, a 170 MW / 340 MWh BESS project", "Liedekerke attends EELA 2026, 4-6 June 2026 in Oslo", "ESG Enforcement & Litigation in Europe: Liedekerke Contributes to Lexology Panoramic Next 2026", "Insights", "Independence", "Legal excellence", "Pragmatic solutions", "Our Values", "Liedekerke", "Get in touch", "Useful links", "Stay informed"], "language": "en", "nofollow": false, "final_url": "https://liedekerke.com/en", "logo_image": "https://liedekerke.com/img/certification-iso27001.jpg", "open_graph": {"og:url": "https://liedekerke.com/en", "og:image": "https://liedekerke.com/storage/files/4906e45c-85ec-49ec-8c6c-2f9ba6f7a8a6/og_image_liedekerke-logo-black-rgb.png", "og:title": "Liedekerke - Solid International Service Capability", "og:description": "Founded in 1965 by lawyers committed to legal excellence, Liedekerke is an independent law firm recognized for its leadership and expertise."}, "forms_count": 2, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 18, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCyld0vG4etibMd8iSP4EoyQ/videos"], "facebook": ["https://www.facebook.com/LWWKLAW"], "linkedin": ["https://be.linkedin.com/company/liedekerke-wolters-waelbroeck-kirkpatrick"], "instagram": ["https://www.instagram.com/liedekerkelaw"], "x_twitter": []}, "title_exists": true, "title_length": 64, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://liedekerke.com/en", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://liedekerke.com/robots.txt", "images_with_alt": 18, "sitemap_xml_url": "https://liedekerke.com/sitemap.xml", "meta_description": "Founded in 1965 by lawyers committed to legal excellence, Liedekerke is an independent law firm recognized for its leadership and expertise.", "schema_org_types": ["Organization", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 72, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": true, "navigation_links_count": 59, "meta_description_exists": true, "meta_description_length": 140}	NORMALIZED	curated-demo-be-law-office-liedekerke-brussels:WEBSITE:website:52	2026-06-29 14:38:04.364843
32	43	curated-demo-fr-restaurant-septime-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Menu d'été", "Contacts & réservation", "Horaires d'ouverture", "Les Vignerons", "Réservation"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 25, "images_with_alt": 1, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 74}, "url": "https://www.septime-charonne.fr", "hsts": false, "https": true, "title": ". x X    Septime    X x .", "emails": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/septimeparis", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": null, "noindex": false, "success": true, "contacts": {"emails": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "phones": [], "tel_links": [], "mailto_links": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 5, "h2_texts": ["Menu d'été", "Contacts & réservation", "Horaires d'ouverture", "Les Vignerons", "Réservation"], "language": "fr", "nofollow": false, "final_url": "https://www.septime-charonne.fr", "logo_image": "https://www.septime-charonne.fr/images/septime-logo.svg", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 1, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": ["https://www.instagram.com/septimeparis"], "x_twitter": []}, "title_exists": true, "title_length": 25, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.septime-charonne.fr/robots.txt", "images_with_alt": 1, "sitemap_xml_url": "https://www.septime-charonne.fr/sitemap.xml", "meta_description": "Site officiel du restaurant Septime. 80 rue de Charonne, Paris 11, France.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 8, "internal_links_count": 1, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": true, "navigation_links_count": 14, "meta_description_exists": true, "meta_description_length": 74}	NORMALIZED	curated-demo-fr-restaurant-septime-paris:WEBSITE:website:43	2026-06-29 14:37:29.561045
33	44	curated-demo-fr-hotel-accor-paris-montparnasse	website	{"seo": {"noindex": false, "h1_texts": ["Reinventing Hospitality in the Age of AI"], "h2_texts": ["45+ Brands. 5,800 Hotels.", "Explore Our Universe", "Discover Our Latest News & Highlights", "Get the Latest News from Accor", "Follow us", "Other websites"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 11, "images_with_alt": 3, "schema_org_types": [], "canonical_present": true, "images_without_alt": 11, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 212}, "url": "https://www.accor.com", "hsts": true, "https": true, "title": "Accor Group", "emails": [], "phones": ["1106 2026", "1806 2026", "2406 2026", "2606 2026"], "server": null, "social": {"tiktok": {"url": "https://www.tiktok.com/@accor", "detected": true}, "youtube": {"url": "https://www.youtube.com/c/accor", "detected": true}, "facebook": {"url": "https://www.facebook.com/Accor", "detected": true}, "linkedin": {"url": "https://fr.linkedin.com/company/accor", "detected": true}, "instagram": {"url": "https://www.instagram.com/accor", "detected": true}, "x_twitter": {"url": "https://twitter.com/accor", "detected": true}}, "favicon": "https://group.accor.com/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": ["1106 2026", "1806 2026", "2406 2026", "2606 2026"], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://group.accor.com/en/contact-hotel-development-team", "https://group.accor.com/en/contact/contact-us", "https://group.accor.com/en/contact/newsletter"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Reinventing Hospitality in the Age of AI"], "h2_count": 6, "h2_texts": ["45+ Brands. 5,800 Hotels.", "Explore Our Universe", "Discover Our Latest News & Highlights", "Get the Latest News from Accor", "Follow us", "Other websites"], "language": "en", "nofollow": false, "final_url": "https://group.accor.com/en", "logo_image": "https://group-accor.imgix.net/https%3A%2F%2Fimages.group.accor.com%2Fyrj0orc8tx24%2F1d3oZEWz9hLim71Q8motQv%2F9274b47f3c34fc4201b48226ffda6f2a%2Flogo-accor-pride-month.svg?ixlib=js-3.8.0&w=3840&q=100&auto=format&fit=crop&crop=focalpoint&s=e3bcdb500ce316bed4870b31fb17c0da", "open_graph": {"og:url": null, "og:image": "https://images.group.accor.com/yrj0orc8tx24/7yNFpNlea631SW2tZGgKqK/2dc2079b03534be57d18137b115fa218/ACCOR.COM_Hero-Homepage_AI.jpg?w=3840&q=100&fm=avif", "og:title": "Accor Group", "og:description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces."}, "forms_count": 1, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 14, "social_links": {"tiktok": ["https://www.tiktok.com/@accor"], "youtube": ["https://www.youtube.com/c/accor"], "facebook": ["https://www.facebook.com/Accor"], "linkedin": ["https://fr.linkedin.com/company/accor"], "instagram": ["https://www.instagram.com/accor"], "x_twitter": ["https://twitter.com/accor"]}, "title_exists": true, "title_length": 11, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://images.group.accor.com/yrj0orc8tx24/7yNFpNlea631SW2tZGgKqK/2dc2079b03534be57d18137b115fa218/ACCOR.COM_Hero-Homepage_AI.jpg?w=3840&q=100&fm=avif", "twitter:title": "Accor Group", "twitter:description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces."}, "canonical_url": "https://group.accor.com/en", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 2, "robots_txt_url": "https://group.accor.com/robots.txt", "images_with_alt": 3, "sitemap_xml_url": "https://group.accor.com/icon0.svg?93b16fc5cc631a7a", "meta_description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 11, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 10, "internal_links_count": 103, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 95, "meta_description_exists": true, "meta_description_length": 212}	NORMALIZED	curated-demo-fr-hotel-accor-paris-montparnasse:WEBSITE:website:44	2026-06-29 14:37:30.469982
34	45	curated-demo-tn-dental-clinic-sourire-sousse	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aide et information"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 55, "images_with_alt": 4, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 113}, "url": "https://www.doctolib.fr", "hsts": true, "https": true, "title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ", "detected": true}, "facebook": {"url": "https://www.facebook.com/doctolib", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/doctolib", "detected": true}, "instagram": {"url": "https://www.instagram.com/doctolib", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.doctolib.fr/icon_patient/180x180.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 1, "h2_texts": ["Aide et information"], "language": "fr", "nofollow": false, "final_url": "https://www.doctolib.fr", "logo_image": "https://assets.doctolib.fr/img/cms/logo-blue.png", "open_graph": {"og:url": "https://www.doctolib.fr/", "og:image": "https://assets.doctolib.fr/img/logo_doctolib_square.png", "og:title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "og:description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics"}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 4, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ"], "facebook": ["https://www.facebook.com/doctolib"], "linkedin": ["https://www.linkedin.com/company/doctolib"], "instagram": ["https://www.instagram.com/doctolib"], "x_twitter": []}, "title_exists": true, "title_length": 55, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.doctolib.fr/robots.txt", "images_with_alt": 4, "sitemap_xml_url": "https://www.doctolib.fr/sitemap.xml", "meta_description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 27, "internal_links_count": 71, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 113}	NORMALIZED	curated-demo-tn-dental-clinic-sourire-sousse:WEBSITE:website:45	2026-06-29 14:37:32.100451
35	46	curated-demo-fr-dental-clinic-saint-lazare-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aide et information"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 55, "images_with_alt": 4, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 113}, "url": "https://www.doctolib.fr", "hsts": true, "https": true, "title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ", "detected": true}, "facebook": {"url": "https://www.facebook.com/doctolib", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/doctolib", "detected": true}, "instagram": {"url": "https://www.instagram.com/doctolib", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.doctolib.fr/icon_patient/180x180.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 1, "h2_texts": ["Aide et information"], "language": "fr", "nofollow": false, "final_url": "https://www.doctolib.fr", "logo_image": "https://assets.doctolib.fr/img/cms/logo-blue.png", "open_graph": {"og:url": "https://www.doctolib.fr/", "og:image": "https://assets.doctolib.fr/img/logo_doctolib_square.png", "og:title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "og:description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics"}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 4, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ"], "facebook": ["https://www.facebook.com/doctolib"], "linkedin": ["https://www.linkedin.com/company/doctolib"], "instagram": ["https://www.instagram.com/doctolib"], "x_twitter": []}, "title_exists": true, "title_length": 55, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.doctolib.fr/robots.txt", "images_with_alt": 4, "sitemap_xml_url": "https://www.doctolib.fr/sitemap.xml", "meta_description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 27, "internal_links_count": 71, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 113}	NORMALIZED	curated-demo-fr-dental-clinic-saint-lazare-paris:WEBSITE:website:46	2026-06-29 14:37:38.429178
36	47	curated-demo-tn-digital-agency-kif-lac-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "title_exists": true, "title_length": 40, "images_with_alt": 62, "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 263}, "url": "https://www.tapptic.com", "hsts": true, "https": true, "title": "Tapptic - Intelligent digital interfaces", "emails": [], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/company/tapptic", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon-32x32.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://tapptic.com/contact-us/", "https://www.tapptic.com/contact-us", "https://www.tapptic.com/contact-us/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 31, "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "language": "en-US", "nofollow": false, "final_url": "https://www.tapptic.com", "logo_image": null, "open_graph": {"og:url": "https://www.tapptic.com/", "og:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "og:title": "Tapptic - Intelligent digital interfaces", "og:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "forms_count": 0, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 98, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/company/tapptic"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 40, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "twitter:title": "Tapptic - Intelligent digital interfaces", "twitter:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "canonical_url": "https://www.tapptic.com/", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.tapptic.com/robots.txt", "images_with_alt": 62, "sitemap_xml_url": "https://www.tapptic.com/feed/", "meta_description": "Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.", "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 18, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 6, "meta_description_exists": true, "meta_description_length": 263}	NORMALIZED	curated-demo-tn-digital-agency-kif-lac-tunis:WEBSITE:website:47	2026-06-29 14:37:43.189521
37	48	curated-demo-tn-real-estate-mubawab-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Le 1er site immobilier de la Tunisie", "Tout l'immobilier en         Tunisie en vente ou location!", "Mode de recherche", "41 268 biens immobiliers: \\n\\t\\t\\t\\t\\t\\ttrouvez l'appartement ou la maison de vos rêves, à vendre ou à louer!", "Immobilier Neuf", "Vente", "Location", "Location vacances", "La Marsa", "Hammamet", "La Soukra", "Tunis", "Carthage"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 50, "images_with_alt": 5, "schema_org_types": [], "canonical_present": false, "images_without_alt": 1, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 126}, "url": "https://www.mubawab.tn", "hsts": true, "https": true, "title": "Immobilier Tunisie - 1er site immobilier - Mubawab", "emails": [], "phones": [], "server": "Apache/2.4.37 (CentOS Stream) OpenSSL/1.1.1k", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCNuw_gPfpmxQ9xUVYmVF-kg", "detected": true}, "facebook": {"url": "https://www.facebook.com/Mubawab.tn", "detected": true}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/mubawab.TN", "detected": true}, "x_twitter": {"url": "https://twitter.com/MubawabTunisie", "detected": true}}, "favicon": "https://www.mubawab-media.com/assets/logos/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.mubawab.tn/fr/contact"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 13, "h2_texts": ["Le 1er site immobilier de la Tunisie", "Tout l'immobilier en         Tunisie en vente ou location!", "Mode de recherche", "41 268 biens immobiliers: \\n\\t\\t\\t\\t\\t\\ttrouvez l'appartement ou la maison de vos rêves, à vendre ou à louer!", "Immobilier Neuf", "Vente", "Location", "Location vacances", "La Marsa", "Hammamet", "La Soukra", "Tunis", "Carthage"], "language": "fr", "nofollow": false, "final_url": "https://www.mubawab.tn", "logo_image": "https://www.mubawab-media.com/assets/logos/mubawab.png", "open_graph": {"og:url": "https://www.mubawab.tn/", "og:image": "https://www.mubawab-media.com/assets/logos/favicon.ico", "og:title": "Immobilier Tunisie - 1er site immobilier - Mubawab", "og:description": "Mubawab est le site immobilier leader en Tunisie. Louez, achetez et vendez grâce à la plus large offre immobilière en Tunisie."}, "forms_count": 2, "robots_meta": null, "status_code": 200, "content_type": "text/html;charset=utf-8", "images_count": 6, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCNuw_gPfpmxQ9xUVYmVF-kg"], "facebook": ["https://www.facebook.com/Mubawab.tn"], "linkedin": [], "instagram": ["https://www.instagram.com/mubawab.TN"], "x_twitter": ["https://twitter.com/MubawabTunisie"]}, "title_exists": true, "title_length": 50, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": "site immobilier, Tunisie, mubawab", "redirect_count": 0, "robots_txt_url": "https://www.mubawab.tn/robots.txt", "images_with_alt": 5, "sitemap_xml_url": "https://www.mubawab.tn/sitemap.xml", "meta_description": "Mubawab est le site immobilier leader en Tunisie. Louez, achetez et vendez grâce à la plus large offre immobilière en Tunisie.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 1, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 8, "internal_links_count": 76, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 9, "meta_description_exists": true, "meta_description_length": 126}	NORMALIZED	curated-demo-tn-real-estate-mubawab-tunis:WEBSITE:website:48	2026-06-29 14:37:57.902851
38	49	curated-demo-be-plumber-facq-brussels	website	{"seo": {"noindex": false, "h1_texts": ["T r a n s f o r m e z v o t r e s a l l e d e b a i n s a v e c F a c q"], "h2_texts": ["Comment pouvons-nous vous aider ?", "Nos promotions", "Cadeau : 100 € de Fashioncheque dès 1000 € d'achat GROHE Colors !", "Profitez de 15 % de réduction sur le WC douche Geberit AquaClean Alba", "Recevez jusqu'à 125€ de cashback à l'achat d'une colonne de douche hansgrohe Pulsify ou Raindance Alive", "Profitez de 20 % de réduction sur les plaques de commande Geberit Sigma40", "Profitez des Creation Days chez FACQ pendant tout le mois de juin", "Une chaudière offerte pour l’achat d’une pompe à chaleur Elga Ace de Remeha", "Besoin d’un installateur pour votre nouvelle salle de bains ?", "Facq, le choix malin", "Install+", "Nos outils sont là pour vous aider", "Voir tous nos outils", "Pour une maison plus verte…", "Nos conseils d'expert", "Facq, c'est aussi plus de 50 marques expertes", "Vous êtes un professionnel ?", "Abonnez-vous à notre newsletter", "La salle de bains", "Le chauffage", "La cuisine", "La Maison Verte"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow", "title_exists": true, "title_length": 84, "images_with_alt": 14, "schema_org_types": ["Organization", "PostalAddress"], "canonical_present": true, "images_without_alt": 4, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 164}, "url": "https://www.facq.be", "hsts": true, "https": true, "title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": "https://www.tiktok.com/@facq.salle_de_bains", "detected": true}, "youtube": {"url": "https://www.youtube.com/@facqbathroom", "detected": true}, "facebook": {"url": "https://www.facebook.com/facqBE", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/facq", "detected": true}, "instagram": {"url": "https://www.instagram.com/facqbathroom", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.facq.be/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.facq.be/fr/particuliers/info/contact", "https://www.facq.be/fr/particuliers/salle-de-bains/toilettes/bati-support-et-plaques-de-commande"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["T r a n s f o r m e z v o t r e s a l l e d e b a i n s a v e c F a c q"], "h2_count": 22, "h2_texts": ["Comment pouvons-nous vous aider ?", "Nos promotions", "Cadeau : 100 € de Fashioncheque dès 1000 € d'achat GROHE Colors !", "Profitez de 15 % de réduction sur le WC douche Geberit AquaClean Alba", "Recevez jusqu'à 125€ de cashback à l'achat d'une colonne de douche hansgrohe Pulsify ou Raindance Alive", "Profitez de 20 % de réduction sur les plaques de commande Geberit Sigma40", "Profitez des Creation Days chez FACQ pendant tout le mois de juin", "Une chaudière offerte pour l’achat d’une pompe à chaleur Elga Ace de Remeha", "Besoin d’un installateur pour votre nouvelle salle de bains ?", "Facq, le choix malin", "Install+", "Nos outils sont là pour vous aider", "Voir tous nos outils", "Pour une maison plus verte…", "Nos conseils d'expert", "Facq, c'est aussi plus de 50 marques expertes", "Vous êtes un professionnel ?", "Abonnez-vous à notre newsletter", "La salle de bains", "Le chauffage", "La cuisine", "La Maison Verte"], "language": "fr", "nofollow": false, "final_url": "https://www.facq.be/fr/particuliers", "logo_image": "https://cms.facq.be/uploads/media/sulu-100x100-inset/06/3436-facq-creation-days-logo.png?v=1-0", "open_graph": {"og:url": "https://www.facq.be/fr/particuliers", "og:image": "https://media.facq.be/cdn-cgi/image/format=jpeg,width=1200,height=630,fit=cover/https://media.facq.be/facq/front/general/default.jpg", "og:title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "og:description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux."}, "forms_count": 2, "robots_meta": "index, follow", "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 18, "social_links": {"tiktok": ["https://www.tiktok.com/@facq.salle_de_bains"], "youtube": ["https://www.youtube.com/@facqbathroom"], "facebook": ["https://www.facebook.com/facqBE"], "linkedin": ["https://www.linkedin.com/company/facq"], "instagram": ["https://www.instagram.com/facqbathroom"], "x_twitter": []}, "title_exists": true, "title_length": 84, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://media.facq.be/cdn-cgi/image/format=jpeg,width=1200,height=630,fit=cover/https://media.facq.be/facq/front/general/default.jpg", "twitter:title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "twitter:description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux."}, "canonical_url": "https://www.facq.be/fr/particuliers", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 2, "robots_txt_url": "https://www.facq.be/robots.txt", "images_with_alt": 14, "sitemap_xml_url": "https://www.facq.be/sitemap.xml", "meta_description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux.", "schema_org_types": ["Organization", "PostalAddress"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 4, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 11, "internal_links_count": 155, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 164}	NORMALIZED	curated-demo-be-plumber-facq-brussels:WEBSITE:website:49	2026-06-29 14:37:59.209507
39	50	curated-demo-fr-beauty-salon-dessange-paris	website	{"seo": {"noindex": false, "h1_texts": ["DESSANGE, un savoir-faire coiffure signature pour révéler la beauté de vos cheveux."], "h2_texts": ["Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Profitez de 20% de réduction sur votre première commande avec le code WELCOME20 !", "Symbio Curl, la nouvelle gamme capillaire de Phytodess pour les cheveux bouclés.", "-15% sur tout le site", "Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Dessange chez vous !", "Les produits Signature", "Nos salons de coiffure", "Accédez au programme privilège Dessange", "Nos tendances coiffure et offres exclusives dans votre boite mail", "Une marque engagée !", "Les marques de la Maison"], "nofollow": false, "robots_txt": true, "robots_meta": "INDEX,FOLLOW", "title_exists": true, "title_length": 8, "images_with_alt": 37, "schema_org_types": ["Organization"], "canonical_present": false, "images_without_alt": 5, "open_graph_present": false, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 141}, "url": "https://www.dessange.com", "hsts": true, "https": true, "title": "DESSANGE", "emails": [], "phones": [], "server": null, "social": {"tiktok": {"url": "https://www.tiktok.com/@dessangeparis", "detected": true}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/DESSANGE.Paris", "detected": true}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/dessangeparis", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://dessange.com/static/version1782376712/frontend/Dessange/default/fr_FR/Magento_Theme/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 1, "newsletter_form_detected": true}, "h1_count": 1, "h1_texts": ["DESSANGE, un savoir-faire coiffure signature pour révéler la beauté de vos cheveux."], "h2_count": 14, "h2_texts": ["Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Profitez de 20% de réduction sur votre première commande avec le code WELCOME20 !", "Symbio Curl, la nouvelle gamme capillaire de Phytodess pour les cheveux bouclés.", "-15% sur tout le site", "Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Dessange chez vous !", "Les produits Signature", "Nos salons de coiffure", "Accédez au programme privilège Dessange", "Nos tendances coiffure et offres exclusives dans votre boite mail", "Une marque engagée !", "Les marques de la Maison"], "language": "fr", "nofollow": false, "final_url": "https://dessange.com", "logo_image": "https://dessange.com/static/version1782376712/frontend/Dessange/default/fr_FR/images/logo.svg", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 7, "robots_meta": "INDEX,FOLLOW", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 42, "social_links": {"tiktok": ["https://www.tiktok.com/@dessangeparis"], "youtube": [], "facebook": ["https://www.facebook.com/DESSANGE.Paris"], "linkedin": [], "instagram": ["https://www.instagram.com/dessangeparis"], "x_twitter": []}, "title_exists": true, "title_length": 8, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://dessange.com/robots.txt", "images_with_alt": 37, "sitemap_xml_url": "https://dessange.com/sitemap.xml", "meta_description": "Découvrez la marque DESSANGE : Des lignes de soins capillaires, de coiffants et de maquillage, signatures du style et de l'expertise DESSANGE", "schema_org_types": ["Organization"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 5, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": true, "external_links_count": 19, "internal_links_count": 63, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 47, "meta_description_exists": true, "meta_description_length": 141}	NORMALIZED	curated-demo-fr-beauty-salon-dessange-paris:WEBSITE:website:50	2026-06-29 14:38:01.521076
42	53	curated-demo-tn-law-office-ferchiou-tunis	website	{"seo": {"noindex": false, "h1_texts": ["One of the leading commercial law firms in Tunisia", "With more than 30 years of experience", "The Firm has been consistently involved in Tunisia's high profile projects", "All aspects of Business and Commercial law", "High level negotiating skills", "ABOUT FERCHIOU LAW", "AREAS OF PRACTICE", "OUR STRATEGIC ADVANTAGE", "Victories", "YOUR INITIAL CONSULTATION"], "h2_texts": ["Let’s Get Started on Your Confidential Consultation", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR Alternative Dispute Resolution all forms of mediation", "ADR Alternative Dispute Resolution all forms of mediation", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT"], "nofollow": false, "robots_txt": true, "robots_meta": "noodp, noydir", "title_exists": true, "title_length": 19, "images_with_alt": 15, "schema_org_types": [], "canonical_present": true, "images_without_alt": 6, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 36}, "url": "https://www.ferchioulaw.com", "hsts": true, "https": true, "title": "Ferchiou & Associés", "emails": ["contact@ferchioulaw.com"], "phones": ["+2167 1120 500", "+2167 1350 028"], "server": "openresty/1.25.3.1", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/start/join", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.ferchioulaw.com/wp-content/themes/paperstreet/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": ["contact@ferchioulaw.com"], "phones": ["+2167 1120 500", "+2167 1350 028"], "tel_links": ["+2167 1120 500"], "mailto_links": ["contact@ferchioulaw.com"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.ferchioulaw.com", "https://www.ferchioulaw.com/lets-connect.php", "https://www.ferchioulaw.com/practices/child-support/index.html", "https://www.ferchioulaw.com/practices/spousal-support/index.html"], "contact_form_count": 1, "newsletter_form_detected": false}, "h1_count": 10, "h1_texts": ["One of the leading commercial law firms in Tunisia", "With more than 30 years of experience", "The Firm has been consistently involved in Tunisia's high profile projects", "All aspects of Business and Commercial law", "High level negotiating skills", "ABOUT FERCHIOU LAW", "AREAS OF PRACTICE", "OUR STRATEGIC ADVANTAGE", "Victories", "YOUR INITIAL CONSULTATION"], "h2_count": 20, "h2_texts": ["Let’s Get Started on Your Confidential Consultation", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR Alternative Dispute Resolution all forms of mediation", "ADR Alternative Dispute Resolution all forms of mediation", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "Banking & Finance The Firm has advised on the incorporation of several off-shore banks.", "ADR", "ENERGY OIL & GAZ", "ENERGY OIL & GAZ", "ENVIRONMENT", "ENVIRONMENT", "LABOR & EMPLOYMENT", "LABOR & EMPLOYMENT"], "language": null, "nofollow": false, "final_url": "https://www.ferchioulaw.com", "logo_image": "https://www.ferchioulaw.com/image/logo2.png", "open_graph": {"og:url": "https://www.ferchioulaw.com/", "og:image": "https://www.ferchioulaw.com/image/open-graph-images/opengraph.png", "og:title": "Ferchiou & Associés", "og:description": null}, "forms_count": 3, "robots_meta": "noodp, noydir", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 21, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/start/join"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 19, "twitter_card": {"twitter:card": "summary", "twitter:image": "https://www.ferchioulaw.com/image/open-graph-images/opengraph.png", "twitter:title": "Ferchiou & Associés", "twitter:description": "Leading Business Law Firm In Tunisia."}, "canonical_url": "https://www.ferchioulaw.com/", "error_message": null, "footer_exists": true, "meta_keywords": "ferchiou, ferchiou law firm, ferchiou & associés, business law, droit, droit international, droit des affaires, avocat, avocats, cabinet d'avocats, tunisie, tunisia, conseil, entreprises, corporate, contrats, expertise, real estate, bank et finance, banking, finance, economic law, investissement, investment, judiciaire, tax, taxation, fiscal, international, droit social, droit du travail, droit boursier, ADR, labor and employment, fiscalité, droit public, droit international, droit fiscal, bourse, property, intellectuelle, droit de la concurrence, infrastructure, reglementation, environnement, environment, energie, energy, immobilier, litiges,", "redirect_count": 0, "robots_txt_url": "https://www.ferchioulaw.com/robots.txt", "images_with_alt": 15, "sitemap_xml_url": "https://www.ferchioulaw.com/sitemap.xml", "meta_description": "Leading Business Law Firm In Tunisia", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 6, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 6, "internal_links_count": 19, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 14, "meta_description_exists": true, "meta_description_length": 36}	NORMALIZED	curated-demo-tn-law-office-ferchiou-tunis:WEBSITE:website:53	2026-06-29 14:38:18.897947
43	55	curated-demo-fr-restaurant-septime-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Menu d'été", "Contacts & réservation", "Horaires d'ouverture", "Les Vignerons", "Réservation"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 25, "images_with_alt": 1, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 74}, "url": "https://www.septime-charonne.fr", "hsts": false, "https": true, "title": ". x X    Septime    X x .", "emails": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/septimeparis", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": null, "noindex": false, "success": true, "contacts": {"emails": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "phones": [], "tel_links": [], "mailto_links": ["confirmation@septime-charonne.fr", "presse@septime-charonne.fr", "travailler@septime-charonne.fr"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 5, "h2_texts": ["Menu d'été", "Contacts & réservation", "Horaires d'ouverture", "Les Vignerons", "Réservation"], "language": "fr", "nofollow": false, "final_url": "https://www.septime-charonne.fr", "logo_image": "https://www.septime-charonne.fr/images/septime-logo.svg", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 1, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": ["https://www.instagram.com/septimeparis"], "x_twitter": []}, "title_exists": true, "title_length": 25, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.septime-charonne.fr/robots.txt", "images_with_alt": 1, "sitemap_xml_url": "https://www.septime-charonne.fr/sitemap.xml", "meta_description": "Site officiel du restaurant Septime. 80 rue de Charonne, Paris 11, France.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 8, "internal_links_count": 1, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": true, "navigation_links_count": 14, "meta_description_exists": true, "meta_description_length": 74}	NORMALIZED	curated-demo-fr-restaurant-septime-paris:WEBSITE:website:55	2026-06-29 15:09:48.540945
44	54	curated-demo-tn-bakery-medina-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Pour passer une commande merci de renseigner votre code postal", "Services disponibles", "Adresse et horaires", "En savoir plus", "Les magasins les plus proches de chez vous", "Adresse et horaires", "PAUL sur un plateau !", "PAUL réélu Marque Préférée des Français©", "Devenir Franchisé PAUL"], "nofollow": false, "robots_txt": true, "robots_meta": "INDEX,FOLLOW", "title_exists": true, "title_length": 36, "images_with_alt": 6, "schema_org_types": [], "canonical_present": true, "images_without_alt": 23, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 151}, "url": "https://www.paul.fr", "hsts": false, "https": true, "title": "PAUL : Maison de qualité depuis 1889", "emails": [], "phones": [], "server": null, "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/PAULFranceOfficiel", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/boulangeries-paul", "detected": true}, "instagram": {"url": "https://www.instagram.com/paulfranceofficiel", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.paul.fr/media/favicon/stores/1/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": true}, "h1_count": 0, "h1_texts": [], "h2_count": 9, "h2_texts": ["Pour passer une commande merci de renseigner votre code postal", "Services disponibles", "Adresse et horaires", "En savoir plus", "Les magasins les plus proches de chez vous", "Adresse et horaires", "PAUL sur un plateau !", "PAUL réélu Marque Préférée des Français©", "Devenir Franchisé PAUL"], "language": "fr", "nofollow": false, "final_url": "https://www.paul.fr", "logo_image": "https://www.paul.fr/media/logo/stores/1/MicrosoftTeams-image_24_.png", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 7, "robots_meta": "INDEX,FOLLOW", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 29, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/PAULFranceOfficiel"], "linkedin": ["https://www.linkedin.com/company/boulangeries-paul"], "instagram": ["https://www.instagram.com/paulfranceofficiel"], "x_twitter": []}, "title_exists": true, "title_length": 36, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://www.paul.fr/", "error_message": null, "footer_exists": true, "meta_keywords": "Boulangeries PAUL France", "redirect_count": 0, "robots_txt_url": "https://www.paul.fr/robots.txt", "images_with_alt": 6, "sitemap_xml_url": "https://www.paul.fr/sitemap.xml", "meta_description": "Vous pouvez maintenant commander et réserver votre repas, votre gâteau en ligne sur paul.fr . ✓ Voir les établissements éligibles au click and collect.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 23, "open_graph_present": false, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 5, "internal_links_count": 69, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 9, "meta_description_exists": true, "meta_description_length": 151}	NORMALIZED	curated-demo-tn-bakery-medina-tunis:WEBSITE:website:54	2026-06-29 15:09:49.976375
45	56	curated-demo-fr-bakery-poilane-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": [], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 62, "images_with_alt": 34, "schema_org_types": ["Organization", "SearchAction", "WebSite"], "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 172}, "url": "https://www.poilane.com", "hsts": true, "https": true, "title": "Boulangerie artisanale de pain au levain Paris\\n    \\n – Poilâne", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": "https://www.tiktok.com/@poilane", "detected": true}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/painpoilane", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/s.a-poilane/mycompany", "detected": true}, "instagram": {"url": "https://www.instagram.com/poilane", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.poilane.com/cdn/shop/files/favicon-Poilane-32x32_32x32.png?v=1654504559", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.poilane.com/pages/contact"], "contact_form_count": 0, "newsletter_form_detected": true}, "h1_count": 0, "h1_texts": [], "h2_count": 0, "h2_texts": [], "language": "fr", "nofollow": false, "final_url": "https://www.poilane.com", "logo_image": null, "open_graph": {"og:url": "https://www.poilane.com/", "og:image": null, "og:title": "Boulangerie artisanale de pain au levain Paris", "og:description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous."}, "forms_count": 4, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 34, "social_links": {"tiktok": ["https://www.tiktok.com/@poilane"], "youtube": [], "facebook": ["https://www.facebook.com/painpoilane"], "linkedin": ["https://www.linkedin.com/company/s.a-poilane/mycompany"], "instagram": ["https://www.instagram.com/poilane"], "x_twitter": []}, "title_exists": true, "title_length": 62, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": null, "twitter:title": "Boulangerie artisanale de pain au levain Paris", "twitter:description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous."}, "canonical_url": "https://www.poilane.com/", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.poilane.com/robots.txt", "images_with_alt": 34, "sitemap_xml_url": "https://www.poilane.com/sitemap.xml", "meta_description": "Retrouvez tous nos pains au levain dans nos boulangeries artisanales Poilâne à Paris et à Londres. Commandez en ligne et faites-vous livrer vos pains directement chez vous.", "schema_org_types": ["Organization", "SearchAction", "WebSite"], "technology_hints": {"wix": false, "shopify": true, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 17, "internal_links_count": 66, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 48, "meta_description_exists": true, "meta_description_length": 172}	NORMALIZED	curated-demo-fr-bakery-poilane-paris:WEBSITE:website:56	2026-06-29 15:09:51.08241
46	57	curated-demo-tn-hotel-la-badira-hammamet	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Concept", "Suites", "Gastronomie", "Evénements", "Découverte", "Adresse :", "téléphone :", "Whatsapp :", "e-mail :"], "nofollow": false, "robots_txt": true, "robots_meta": "max-image-preview:large", "title_exists": true, "title_length": 19, "images_with_alt": 28, "schema_org_types": ["BreadcrumbList", "ListItem", "Organization", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 28, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 310}, "url": "https://www.labadira.com", "hsts": false, "https": true, "title": "La badira - Accueil", "emails": ["contact@labadira.com"], "phones": ["2167 0018 180", "2169 4866 672"], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/labadira", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/labadira", "detected": true}, "instagram": {"url": "https://www.instagram.com/la_badira", "detected": true}, "x_twitter": {"url": "https://twitter.com/labadira", "detected": true}}, "favicon": "https://www.labadira.com/wp-content/themes/badira/images/favicon.png", "noindex": false, "success": true, "contacts": {"emails": ["contact@labadira.com"], "phones": ["2167 0018 180", "2169 4866 672"], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.labadira.com/contact/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 9, "h2_texts": ["Concept", "Suites", "Gastronomie", "Evénements", "Découverte", "Adresse :", "téléphone :", "Whatsapp :", "e-mail :"], "language": "fr-FR", "nofollow": false, "final_url": "https://www.labadira.com", "logo_image": "https://www.labadira.com/wp-content/themes/badira/images/logo-badira-10-w.png.webp", "open_graph": {"og:url": "https://www.labadira.com/", "og:image": "https://www.labadira.com/wp-content/uploads/2020/06/slider1.jpg", "og:title": "Hôtel 5 étoiles - Membre de Leading Hotels of the World", "og:description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel."}, "forms_count": 2, "robots_meta": "max-image-preview:large", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 56, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/labadira"], "linkedin": ["https://www.linkedin.com/company/labadira"], "instagram": ["https://www.instagram.com/la_badira"], "x_twitter": ["https://twitter.com/labadira"]}, "title_exists": true, "title_length": 19, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.labadira.com/wp-content/uploads/2020/06/slider1.jpg", "twitter:title": "Hôtel 5 étoiles - Membre de Leading Hotels of the World", "twitter:description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel."}, "canonical_url": "https://www.labadira.com/", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.labadira.com/robots.txt", "images_with_alt": 28, "sitemap_xml_url": "https://www.labadira.com/feed/", "meta_description": "Le nom \\"Badira : aussi lumineuse que la pleine lune\\" apparait comme une évidence. Jouant sur le principe de l'ombre et de la lumière, cher aux artistes qui fréquentent Hammamet depuis le début du XXème siècle, sa sonorité inspire un univers poétique empreint de sérénité. Tout ce qui fait l'essence de l’hôtel.", "schema_org_types": ["BreadcrumbList", "ListItem", "Organization", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 28, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 10, "internal_links_count": 22, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 310}	NORMALIZED	curated-demo-tn-hotel-la-badira-hammamet:WEBSITE:website:57	2026-06-29 15:09:52.749867
47	58	curated-demo-fr-hotel-accor-paris-montparnasse	website	{"seo": {"noindex": false, "h1_texts": ["Reinventing Hospitality in the Age of AI"], "h2_texts": ["45+ Brands. 5,800 Hotels.", "Explore Our Universe", "Discover Our Latest News & Highlights", "Get the Latest News from Accor", "Follow us", "Other websites"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 11, "images_with_alt": 3, "schema_org_types": [], "canonical_present": true, "images_without_alt": 11, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 212}, "url": "https://www.accor.com", "hsts": true, "https": true, "title": "Accor Group", "emails": [], "phones": ["1106 2026", "1806 2026", "2406 2026", "2606 2026"], "server": null, "social": {"tiktok": {"url": "https://www.tiktok.com/@accor", "detected": true}, "youtube": {"url": "https://www.youtube.com/c/accor", "detected": true}, "facebook": {"url": "https://www.facebook.com/Accor", "detected": true}, "linkedin": {"url": "https://fr.linkedin.com/company/accor", "detected": true}, "instagram": {"url": "https://www.instagram.com/accor", "detected": true}, "x_twitter": {"url": "https://twitter.com/accor", "detected": true}}, "favicon": "https://group.accor.com/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": ["1106 2026", "1806 2026", "2406 2026", "2606 2026"], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://group.accor.com/en/contact-hotel-development-team", "https://group.accor.com/en/contact/contact-us", "https://group.accor.com/en/contact/newsletter"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Reinventing Hospitality in the Age of AI"], "h2_count": 6, "h2_texts": ["45+ Brands. 5,800 Hotels.", "Explore Our Universe", "Discover Our Latest News & Highlights", "Get the Latest News from Accor", "Follow us", "Other websites"], "language": "en", "nofollow": false, "final_url": "https://group.accor.com/en", "logo_image": "https://group-accor.imgix.net/https%3A%2F%2Fimages.group.accor.com%2Fyrj0orc8tx24%2F1d3oZEWz9hLim71Q8motQv%2F9274b47f3c34fc4201b48226ffda6f2a%2Flogo-accor-pride-month.svg?ixlib=js-3.8.0&w=3840&q=100&auto=format&fit=crop&crop=focalpoint&s=e3bcdb500ce316bed4870b31fb17c0da", "open_graph": {"og:url": null, "og:image": "https://images.group.accor.com/yrj0orc8tx24/7yNFpNlea631SW2tZGgKqK/2dc2079b03534be57d18137b115fa218/ACCOR.COM_Hero-Homepage_AI.jpg?w=3840&q=100&fm=avif", "og:title": "Accor Group", "og:description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces."}, "forms_count": 1, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 14, "social_links": {"tiktok": ["https://www.tiktok.com/@accor"], "youtube": ["https://www.youtube.com/c/accor"], "facebook": ["https://www.facebook.com/Accor"], "linkedin": ["https://fr.linkedin.com/company/accor"], "instagram": ["https://www.instagram.com/accor"], "x_twitter": ["https://twitter.com/accor"]}, "title_exists": true, "title_length": 11, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://images.group.accor.com/yrj0orc8tx24/7yNFpNlea631SW2tZGgKqK/2dc2079b03534be57d18137b115fa218/ACCOR.COM_Hero-Homepage_AI.jpg?w=3840&q=100&fm=avif", "twitter:title": "Accor Group", "twitter:description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces."}, "canonical_url": "https://group.accor.com/en", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 2, "robots_txt_url": "https://group.accor.com/robots.txt", "images_with_alt": 3, "sitemap_xml_url": "https://group.accor.com/icon0.svg?93b16fc5cc631a7a", "meta_description": "Accor is a world-leading hospitality group offering stays and experiences across more than 110 countries with over 5,800 hotels and resorts, 10,000 bars & restaurants, wellness facilities and flexible workspaces.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 11, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 10, "internal_links_count": 103, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 95, "meta_description_exists": true, "meta_description_length": 212}	NORMALIZED	curated-demo-fr-hotel-accor-paris-montparnasse:WEBSITE:website:58	2026-06-29 15:09:54.554174
56	67	curated-demo-fr-car-repair-norauto-lyon	website	{"seo": {"noindex": true, "h1_texts": [], "h2_texts": [], "nofollow": true, "robots_txt": false, "robots_meta": "noindex,nofollow", "title_exists": true, "title_length": 16, "images_with_alt": 0, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": false, "meta_description_length": 0}, "url": "https://www.norauto.fr", "hsts": false, "https": true, "title": "Just a moment...", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": null, "noindex": true, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 0, "h2_texts": [], "language": "en-US", "nofollow": true, "final_url": "https://www.norauto.fr", "logo_image": null, "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": "noindex,nofollow", "status_code": 403, "content_type": "text/html; charset=UTF-8", "images_count": 0, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": [], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 16, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.norauto.fr/robots.txt", "images_with_alt": 0, "sitemap_xml_url": "https://www.norauto.fr/sitemap.xml", "meta_description": null, "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 0, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 0, "internal_links_count": 0, "meta_keywords_exists": false, "robots_txt_available": false, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": false, "meta_description_length": 0}	NORMALIZED	curated-demo-fr-car-repair-norauto-lyon:WEBSITE:website:67	2026-06-29 15:10:52.067309
48	59	curated-demo-tn-dental-clinic-sourire-sousse	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aide et information"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 55, "images_with_alt": 4, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 113}, "url": "https://www.doctolib.fr", "hsts": true, "https": true, "title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ", "detected": true}, "facebook": {"url": "https://www.facebook.com/doctolib", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/doctolib", "detected": true}, "instagram": {"url": "https://www.instagram.com/doctolib", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.doctolib.fr/icon_patient/180x180.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 1, "h2_texts": ["Aide et information"], "language": "fr", "nofollow": false, "final_url": "https://www.doctolib.fr", "logo_image": "https://assets.doctolib.fr/img/cms/logo-blue.png", "open_graph": {"og:url": "https://www.doctolib.fr/", "og:image": "https://assets.doctolib.fr/img/logo_doctolib_square.png", "og:title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "og:description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics"}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 4, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ"], "facebook": ["https://www.facebook.com/doctolib"], "linkedin": ["https://www.linkedin.com/company/doctolib"], "instagram": ["https://www.instagram.com/doctolib"], "x_twitter": []}, "title_exists": true, "title_length": 55, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.doctolib.fr/robots.txt", "images_with_alt": 4, "sitemap_xml_url": "https://www.doctolib.fr/sitemap.xml", "meta_description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 27, "internal_links_count": 71, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 113}	NORMALIZED	curated-demo-tn-dental-clinic-sourire-sousse:WEBSITE:website:59	2026-06-29 15:10:09.478501
49	60	curated-demo-fr-dental-clinic-saint-lazare-paris	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aide et information"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 55, "images_with_alt": 4, "schema_org_types": [], "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 113}, "url": "https://www.doctolib.fr", "hsts": true, "https": true, "title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ", "detected": true}, "facebook": {"url": "https://www.facebook.com/doctolib", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/doctolib", "detected": true}, "instagram": {"url": "https://www.instagram.com/doctolib", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.doctolib.fr/icon_patient/180x180.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 1, "h2_texts": ["Aide et information"], "language": "fr", "nofollow": false, "final_url": "https://www.doctolib.fr", "logo_image": "https://assets.doctolib.fr/img/cms/logo-blue.png", "open_graph": {"og:url": "https://www.doctolib.fr/", "og:image": "https://assets.doctolib.fr/img/logo_doctolib_square.png", "og:title": "Doctolib : Prenez rendez-vous en ligne chez un soignant", "og:description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics"}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 4, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCUK-4icPVFFvnFvUCKh7wsQ"], "facebook": ["https://www.facebook.com/doctolib"], "linkedin": ["https://www.linkedin.com/company/doctolib"], "instagram": ["https://www.instagram.com/doctolib"], "x_twitter": []}, "title_exists": true, "title_length": 55, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.doctolib.fr/robots.txt", "images_with_alt": 4, "sitemap_xml_url": "https://www.doctolib.fr/sitemap.xml", "meta_description": "Trouvez rapidement un spécialiste près de chez vous et prenez rendez-vous gratuitement en ligne en quelques clics", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": false}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": false, "schema_org_detected": false, "external_links_count": 27, "internal_links_count": 71, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 113}	NORMALIZED	curated-demo-fr-dental-clinic-saint-lazare-paris:WEBSITE:website:60	2026-06-29 15:10:15.928843
50	62	curated-demo-tn-digital-agency-kif-lac-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "title_exists": true, "title_length": 40, "images_with_alt": 62, "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 263}, "url": "https://www.tapptic.com", "hsts": true, "https": true, "title": "Tapptic - Intelligent digital interfaces", "emails": [], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/company/tapptic", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon-32x32.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://tapptic.com/contact-us/", "https://www.tapptic.com/contact-us", "https://www.tapptic.com/contact-us/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 31, "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "language": "en-US", "nofollow": false, "final_url": "https://www.tapptic.com", "logo_image": null, "open_graph": {"og:url": "https://www.tapptic.com/", "og:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "og:title": "Tapptic - Intelligent digital interfaces", "og:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "forms_count": 0, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 98, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/company/tapptic"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 40, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "twitter:title": "Tapptic - Intelligent digital interfaces", "twitter:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "canonical_url": "https://www.tapptic.com/", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.tapptic.com/robots.txt", "images_with_alt": 62, "sitemap_xml_url": "https://www.tapptic.com/feed/", "meta_description": "Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.", "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 18, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 6, "meta_description_exists": true, "meta_description_length": 263}	NORMALIZED	curated-demo-tn-digital-agency-kif-lac-tunis:WEBSITE:website:62	2026-06-29 15:10:22.122618
51	61	curated-demo-tn-real-estate-mubawab-tunis	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Le 1er site immobilier de la Tunisie", "Tout l'immobilier en         Tunisie en vente ou location!", "Mode de recherche", "41 251 biens immobiliers: \\n\\t\\t\\t\\t\\t\\ttrouvez l'appartement ou la maison de vos rêves, à vendre ou à louer!", "Immobilier Neuf", "Vente", "Location", "Location vacances", "La Marsa", "Hammamet", "La Soukra", "Tunis", "Carthage"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 50, "images_with_alt": 5, "schema_org_types": [], "canonical_present": false, "images_without_alt": 1, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": true, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 126}, "url": "https://www.mubawab.tn", "hsts": true, "https": true, "title": "Immobilier Tunisie - 1er site immobilier - Mubawab", "emails": [], "phones": [], "server": "Apache/2.4.37 (CentOS Stream) OpenSSL/1.1.1k", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCNuw_gPfpmxQ9xUVYmVF-kg", "detected": true}, "facebook": {"url": "https://www.facebook.com/Mubawab.tn", "detected": true}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/mubawab.TN", "detected": true}, "x_twitter": {"url": "https://twitter.com/MubawabTunisie", "detected": true}}, "favicon": "https://www.mubawab-media.com/assets/logos/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.mubawab.tn/fr/contact"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 13, "h2_texts": ["Le 1er site immobilier de la Tunisie", "Tout l'immobilier en         Tunisie en vente ou location!", "Mode de recherche", "41 251 biens immobiliers: \\n\\t\\t\\t\\t\\t\\ttrouvez l'appartement ou la maison de vos rêves, à vendre ou à louer!", "Immobilier Neuf", "Vente", "Location", "Location vacances", "La Marsa", "Hammamet", "La Soukra", "Tunis", "Carthage"], "language": "fr", "nofollow": false, "final_url": "https://www.mubawab.tn", "logo_image": "https://www.mubawab-media.com/assets/logos/mubawab.png", "open_graph": {"og:url": "https://www.mubawab.tn/", "og:image": "https://www.mubawab-media.com/assets/logos/favicon.ico", "og:title": "Immobilier Tunisie - 1er site immobilier - Mubawab", "og:description": "Mubawab est le site immobilier leader en Tunisie. Louez, achetez et vendez grâce à la plus large offre immobilière en Tunisie."}, "forms_count": 2, "robots_meta": null, "status_code": 200, "content_type": "text/html;charset=utf-8", "images_count": 6, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCNuw_gPfpmxQ9xUVYmVF-kg"], "facebook": ["https://www.facebook.com/Mubawab.tn"], "linkedin": [], "instagram": ["https://www.instagram.com/mubawab.TN"], "x_twitter": ["https://twitter.com/MubawabTunisie"]}, "title_exists": true, "title_length": 50, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": "site immobilier, Tunisie, mubawab", "redirect_count": 0, "robots_txt_url": "https://www.mubawab.tn/robots.txt", "images_with_alt": 5, "sitemap_xml_url": "https://www.mubawab.tn/sitemap.xml", "meta_description": "Mubawab est le site immobilier leader en Tunisie. Louez, achetez et vendez grâce à la plus large offre immobilière en Tunisie.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": false, "images_without_alt": 1, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 8, "internal_links_count": 76, "meta_keywords_exists": true, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 9, "meta_description_exists": true, "meta_description_length": 126}	NORMALIZED	curated-demo-tn-real-estate-mubawab-tunis:WEBSITE:website:61	2026-06-29 15:10:26.897637
52	63	curated-demo-be-digital-agency-tapptic-brussels	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "title_exists": true, "title_length": 40, "images_with_alt": 62, "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 263}, "url": "https://www.tapptic.com", "hsts": true, "https": true, "title": "Tapptic - Intelligent digital interfaces", "emails": [], "phones": [], "server": "Apache", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": null, "detected": false}, "linkedin": {"url": "https://www.linkedin.com/company/tapptic", "detected": true}, "instagram": {"url": null, "detected": false}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon-32x32.png", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://tapptic.com/contact-us/", "https://www.tapptic.com/contact-us", "https://www.tapptic.com/contact-us/"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 31, "h2_texts": ["Intelligent Digital", "Interfaces.", "500+", "About Us", "A  trusted partner helping enterprises to think, design & build digital ecosystems", "Flexible delivery models designed for your business challenges", "Leverage our expertise", "We master the most advanced technologies and solutions", "Case Studies", "Monoprix", "FIBA", "TEC", "Carrefour", "Euroconsumers", "Buy Way", "Sarenza", "Buy Way", "Euroconsumers", "Monoprix", "What we do", "01.", "Digital \\nStrategy", "02.", "UX/UI\\nDesign", "03.", "Development", "04.", "AI Agents", "Frequently\\nasked questions", "MAKE YOUR DIGITAL INTERFACES YOUR COMPETITIVE EDGE", "Insights & Expertise"], "language": "en-US", "nofollow": false, "final_url": "https://www.tapptic.com", "logo_image": null, "open_graph": {"og:url": "https://www.tapptic.com/", "og:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "og:title": "Tapptic - Intelligent digital interfaces", "og:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "forms_count": 0, "robots_meta": "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 98, "social_links": {"tiktok": [], "youtube": [], "facebook": [], "linkedin": ["https://www.linkedin.com/company/tapptic"], "instagram": [], "x_twitter": []}, "title_exists": true, "title_length": 40, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://www.tapptic.com/wp-content/uploads/2026/03/cropped-Favicon.png", "twitter:title": "Tapptic - Intelligent digital interfaces", "twitter:description": "Mobile Apps-Web Platform s- AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI."}, "canonical_url": "https://www.tapptic.com/", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 0, "robots_txt_url": "https://www.tapptic.com/robots.txt", "images_with_alt": 62, "sitemap_xml_url": "https://www.tapptic.com/feed/", "meta_description": "Mobile Apps-Web Platforms - AI Agents. We are a technology consulting firm specializing in digital strategy, UX/UI design, web and mobile development, helping organizations deliver robust digital products on modern headless and composable platforms powered by AI.", "schema_org_types": ["BreadcrumbList", "EntryPoint", "ImageObject", "ListItem", "Organization", "PropertyValueSpecification", "ReadAction", "SearchAction", "WebPage", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": true, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 36, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 18, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 6, "meta_description_exists": true, "meta_description_length": 263}	NORMALIZED	curated-demo-be-digital-agency-tapptic-brussels:WEBSITE:website:63	2026-06-29 15:10:28.219531
53	64	curated-demo-be-real-estate-century21-brussels	website	{"seo": {"noindex": false, "h1_texts": [], "h2_texts": ["Aarschot", "Anderlecht", "Antwerpen", "Brussels", "Charleroi", "Ciney", "Gent", "Halle", "Koksijde", "Kortrijk", "Leuven", "Luik", "Mechelen", "Middelkerke", "Bergen", "Namen", "Nieuwpoort", "Schaarbeek", "Zinnik", "Doornik"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 62, "images_with_alt": 2, "schema_org_types": [], "canonical_present": true, "images_without_alt": 115, "open_graph_present": true, "schema_org_detected": false, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 109}, "url": "https://www.century21.be", "hsts": false, "https": true, "title": "Nummer 1 netwerk van vastgoed makelaars in België en Luxemburg", "emails": [], "phones": [], "server": "AmazonS3", "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/Century21Benelux", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/century21benelux", "detected": true}, "instagram": {"url": "https://www.instagram.com/century21_bnl", "detected": true}, "x_twitter": {"url": "https://twitter.com/Century21_bnl", "detected": true}}, "favicon": "https://www.century21.be/favicon-32x32.png?v=abba4c6b216924630502358f2136b5ea", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.century21.be/nl/contacteer-ons"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 0, "h1_texts": [], "h2_count": 20, "h2_texts": ["Aarschot", "Anderlecht", "Antwerpen", "Brussels", "Charleroi", "Ciney", "Gent", "Halle", "Koksijde", "Kortrijk", "Leuven", "Luik", "Mechelen", "Middelkerke", "Bergen", "Namen", "Nieuwpoort", "Schaarbeek", "Zinnik", "Doornik"], "language": "nl", "nofollow": false, "final_url": "https://www.century21.be/nl", "logo_image": null, "open_graph": {"og:url": "https://www.century21.be/nl", "og:image": null, "og:title": null, "og:description": null}, "forms_count": 0, "robots_meta": null, "status_code": 200, "content_type": "text/html", "images_count": 117, "social_links": {"tiktok": [], "youtube": [], "facebook": ["https://www.facebook.com/Century21Benelux"], "linkedin": ["https://www.linkedin.com/company/century21benelux"], "instagram": ["https://www.instagram.com/century21_bnl"], "x_twitter": ["https://twitter.com/Century21_bnl"]}, "title_exists": true, "title_length": 62, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://www.century21.be/nl", "error_message": null, "footer_exists": false, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://www.century21.be/robots.txt", "images_with_alt": 2, "sitemap_xml_url": "https://www.century21.be/sitemap/all-pages/sitemap-index.xml", "meta_description": "Het leidende netwerk van vastgoed makelaars in België . Ontdek onze diensten en zoek een kantoor in je buurt.", "schema_org_types": [], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 115, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": false, "external_links_count": 7, "internal_links_count": 85, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": true, "navigation_links_count": 5, "meta_description_exists": true, "meta_description_length": 109}	NORMALIZED	curated-demo-be-real-estate-century21-brussels:WEBSITE:website:64	2026-06-29 15:10:44.69648
54	65	curated-demo-be-plumber-facq-brussels	website	{"seo": {"noindex": false, "h1_texts": ["T r a n s f o r m e z v o t r e s a l l e d e b a i n s a v e c F a c q"], "h2_texts": ["Comment pouvons-nous vous aider ?", "Nos promotions", "Cadeau : 100 € de Fashioncheque dès 1000 € d'achat GROHE Colors !", "Profitez de 15 % de réduction sur le WC douche Geberit AquaClean Alba", "Recevez jusqu'à 125€ de cashback à l'achat d'une colonne de douche hansgrohe Pulsify ou Raindance Alive", "Profitez de 20 % de réduction sur les plaques de commande Geberit Sigma40", "Profitez des Creation Days chez FACQ pendant tout le mois de juin", "Une chaudière offerte pour l’achat d’une pompe à chaleur Elga Ace de Remeha", "Besoin d’un installateur pour votre nouvelle salle de bains ?", "Facq, le choix malin", "Install+", "Nos outils sont là pour vous aider", "Voir tous nos outils", "Pour une maison plus verte…", "Nos conseils d'expert", "Facq, c'est aussi plus de 50 marques expertes", "Vous êtes un professionnel ?", "Abonnez-vous à notre newsletter", "La salle de bains", "Le chauffage", "La cuisine", "La Maison Verte"], "nofollow": false, "robots_txt": true, "robots_meta": "index, follow", "title_exists": true, "title_length": 84, "images_with_alt": 14, "schema_org_types": ["Organization", "PostalAddress"], "canonical_present": true, "images_without_alt": 4, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": true, "meta_description_exists": true, "meta_description_length": 164}, "url": "https://www.facq.be", "hsts": true, "https": true, "title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "emails": [], "phones": [], "server": "cloudflare", "social": {"tiktok": {"url": "https://www.tiktok.com/@facq.salle_de_bains", "detected": true}, "youtube": {"url": "https://www.youtube.com/@facqbathroom", "detected": true}, "facebook": {"url": "https://www.facebook.com/facqBE", "detected": true}, "linkedin": {"url": "https://www.linkedin.com/company/facq", "detected": true}, "instagram": {"url": "https://www.instagram.com/facqbathroom", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://www.facq.be/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://www.facq.be/fr/particuliers/info/contact", "https://www.facq.be/fr/particuliers/salle-de-bains/toilettes/bati-support-et-plaques-de-commande"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["T r a n s f o r m e z v o t r e s a l l e d e b a i n s a v e c F a c q"], "h2_count": 22, "h2_texts": ["Comment pouvons-nous vous aider ?", "Nos promotions", "Cadeau : 100 € de Fashioncheque dès 1000 € d'achat GROHE Colors !", "Profitez de 15 % de réduction sur le WC douche Geberit AquaClean Alba", "Recevez jusqu'à 125€ de cashback à l'achat d'une colonne de douche hansgrohe Pulsify ou Raindance Alive", "Profitez de 20 % de réduction sur les plaques de commande Geberit Sigma40", "Profitez des Creation Days chez FACQ pendant tout le mois de juin", "Une chaudière offerte pour l’achat d’une pompe à chaleur Elga Ace de Remeha", "Besoin d’un installateur pour votre nouvelle salle de bains ?", "Facq, le choix malin", "Install+", "Nos outils sont là pour vous aider", "Voir tous nos outils", "Pour une maison plus verte…", "Nos conseils d'expert", "Facq, c'est aussi plus de 50 marques expertes", "Vous êtes un professionnel ?", "Abonnez-vous à notre newsletter", "La salle de bains", "Le chauffage", "La cuisine", "La Maison Verte"], "language": "fr", "nofollow": false, "final_url": "https://www.facq.be/fr/particuliers", "logo_image": "https://cms.facq.be/uploads/media/sulu-100x100-inset/06/3436-facq-creation-days-logo.png?v=1-0", "open_graph": {"og:url": "https://www.facq.be/fr/particuliers", "og:image": "https://media.facq.be/cdn-cgi/image/format=jpeg,width=1200,height=630,fit=cover/https://media.facq.be/facq/front/general/default.jpg", "og:title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "og:description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux."}, "forms_count": 2, "robots_meta": "index, follow", "status_code": 200, "content_type": "text/html; charset=utf-8", "images_count": 18, "social_links": {"tiktok": ["https://www.tiktok.com/@facq.salle_de_bains"], "youtube": ["https://www.youtube.com/@facqbathroom"], "facebook": ["https://www.facebook.com/facqBE"], "linkedin": ["https://www.linkedin.com/company/facq"], "instagram": ["https://www.instagram.com/facqbathroom"], "x_twitter": []}, "title_exists": true, "title_length": 84, "twitter_card": {"twitter:card": "summary_large_image", "twitter:image": "https://media.facq.be/cdn-cgi/image/format=jpeg,width=1200,height=630,fit=cover/https://media.facq.be/facq/front/general/default.jpg", "twitter:title": "Facq salle de bain et chauffage - Le spécialiste du sanitaire et du chauffage | Facq", "twitter:description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux."}, "canonical_url": "https://www.facq.be/fr/particuliers", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 2, "robots_txt_url": "https://www.facq.be/robots.txt", "images_with_alt": 14, "sitemap_xml_url": "https://www.facq.be/sitemap.xml", "meta_description": "Découvrez les dernières tendances en matière de sanitaires et chauffage chez Facq. Nos experts vous accueillent dans nos showrooms et vous y conseilleront au mieux.", "schema_org_types": ["Organization", "PostalAddress"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": true, "images_without_alt": 4, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 11, "internal_links_count": 155, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": true, "sitemap_xml_available": false, "navigation_links_count": 0, "meta_description_exists": true, "meta_description_length": 164}	NORMALIZED	curated-demo-be-plumber-facq-brussels:WEBSITE:website:65	2026-06-29 15:10:47.615984
55	66	curated-demo-fr-beauty-salon-dessange-paris	website	{"seo": {"noindex": false, "h1_texts": ["DESSANGE, un savoir-faire coiffure signature pour révéler la beauté de vos cheveux."], "h2_texts": ["Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Profitez de 20% de réduction sur votre première commande avec le code WELCOME20 !", "Symbio Curl, la nouvelle gamme capillaire de Phytodess pour les cheveux bouclés.", "-15% sur tout le site", "Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Dessange chez vous !", "Les produits Signature", "Nos salons de coiffure", "Accédez au programme privilège Dessange", "Nos tendances coiffure et offres exclusives dans votre boite mail", "Une marque engagée !", "Les marques de la Maison"], "nofollow": false, "robots_txt": true, "robots_meta": "INDEX,FOLLOW", "title_exists": true, "title_length": 8, "images_with_alt": 37, "schema_org_types": ["Organization"], "canonical_present": false, "images_without_alt": 5, "open_graph_present": false, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 141}, "url": "https://www.dessange.com", "hsts": true, "https": true, "title": "DESSANGE", "emails": [], "phones": [], "server": null, "social": {"tiktok": {"url": "https://www.tiktok.com/@dessangeparis", "detected": true}, "youtube": {"url": null, "detected": false}, "facebook": {"url": "https://www.facebook.com/DESSANGE.Paris", "detected": true}, "linkedin": {"url": null, "detected": false}, "instagram": {"url": "https://www.instagram.com/dessangeparis", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://dessange.com/static/version1782376712/frontend/Dessange/default/fr_FR/Magento_Theme/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": [], "phones": [], "tel_links": [], "mailto_links": [], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": [], "contact_form_count": 1, "newsletter_form_detected": true}, "h1_count": 1, "h1_texts": ["DESSANGE, un savoir-faire coiffure signature pour révéler la beauté de vos cheveux."], "h2_count": 14, "h2_texts": ["Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Profitez de 20% de réduction sur votre première commande avec le code WELCOME20 !", "Symbio Curl, la nouvelle gamme capillaire de Phytodess pour les cheveux bouclés.", "-15% sur tout le site", "Profitez de réductions exclusives sur tout le site !", "Découvrez les Produits Signature, des soins d’exception conçus par DESSANGE Paris !", "Dessange chez vous !", "Les produits Signature", "Nos salons de coiffure", "Accédez au programme privilège Dessange", "Nos tendances coiffure et offres exclusives dans votre boite mail", "Une marque engagée !", "Les marques de la Maison"], "language": "fr", "nofollow": false, "final_url": "https://dessange.com", "logo_image": "https://dessange.com/static/version1782376712/frontend/Dessange/default/fr_FR/images/logo.svg", "open_graph": {"og:url": null, "og:image": null, "og:title": null, "og:description": null}, "forms_count": 7, "robots_meta": "INDEX,FOLLOW", "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 42, "social_links": {"tiktok": ["https://www.tiktok.com/@dessangeparis"], "youtube": [], "facebook": ["https://www.facebook.com/DESSANGE.Paris"], "linkedin": [], "instagram": ["https://www.instagram.com/dessangeparis"], "x_twitter": []}, "title_exists": true, "title_length": 8, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": null, "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://dessange.com/robots.txt", "images_with_alt": 37, "sitemap_xml_url": "https://dessange.com/sitemap.xml", "meta_description": "Découvrez la marque DESSANGE : Des lignes de soins capillaires, de coiffants et de maquillage, signatures du style et de l'expertise DESSANGE", "schema_org_types": ["Organization"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": true, "google_tag_manager": true}, "about_page_exists": false, "canonical_present": false, "images_without_alt": 5, "open_graph_present": false, "contact_page_exists": false, "schema_org_detected": true, "external_links_count": 19, "internal_links_count": 63, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": false, "navigation_links_count": 47, "meta_description_exists": true, "meta_description_length": 141}	NORMALIZED	curated-demo-fr-beauty-salon-dessange-paris:WEBSITE:website:66	2026-06-29 15:10:49.266297
57	68	curated-demo-be-law-office-liedekerke-brussels	website	{"seo": {"noindex": false, "h1_texts": ["Solid International Service Strong local expertise"], "h2_texts": ["Latest news", "Liedekerke advises Aukera Energy on the project financing of Volt, a 170 MW / 340 MWh BESS project", "Liedekerke attends EELA 2026, 4-6 June 2026 in Oslo", "ESG Enforcement & Litigation in Europe: Liedekerke Contributes to Lexology Panoramic Next 2026", "Insights", "Independence", "Legal excellence", "Pragmatic solutions", "Our Values", "Liedekerke", "Get in touch", "Useful links", "Stay informed"], "nofollow": false, "robots_txt": true, "robots_meta": null, "title_exists": true, "title_length": 64, "images_with_alt": 18, "schema_org_types": ["Organization", "WebSite"], "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "schema_org_detected": true, "meta_keywords_exists": false, "twitter_card_present": false, "meta_description_exists": true, "meta_description_length": 140}, "url": "https://liedekerke.com", "hsts": false, "https": true, "title": "Liedekerke - Solid International Service Capability | Liedekerke", "emails": ["info@liedekerke.com"], "phones": ["+3225 5115 15"], "server": null, "social": {"tiktok": {"url": null, "detected": false}, "youtube": {"url": "https://www.youtube.com/channel/UCyld0vG4etibMd8iSP4EoyQ/videos", "detected": true}, "facebook": {"url": "https://www.facebook.com/LWWKLAW", "detected": true}, "linkedin": {"url": "https://be.linkedin.com/company/liedekerke-wolters-waelbroeck-kirkpatrick", "detected": true}, "instagram": {"url": "https://www.instagram.com/liedekerkelaw", "detected": true}, "x_twitter": {"url": null, "detected": false}}, "favicon": "https://liedekerke.com/favicon.ico", "noindex": false, "success": true, "contacts": {"emails": ["info@liedekerke.com"], "phones": ["+3225 5115 15"], "tel_links": ["+3225 5115 15"], "mailto_links": ["info@liedekerke.com"], "whatsapp_links": [], "address_snippets": [], "contact_page_urls": ["https://liedekerke.com/en/contact"], "contact_form_count": 0, "newsletter_form_detected": false}, "h1_count": 1, "h1_texts": ["Solid International Service Strong local expertise"], "h2_count": 13, "h2_texts": ["Latest news", "Liedekerke advises Aukera Energy on the project financing of Volt, a 170 MW / 340 MWh BESS project", "Liedekerke attends EELA 2026, 4-6 June 2026 in Oslo", "ESG Enforcement & Litigation in Europe: Liedekerke Contributes to Lexology Panoramic Next 2026", "Insights", "Independence", "Legal excellence", "Pragmatic solutions", "Our Values", "Liedekerke", "Get in touch", "Useful links", "Stay informed"], "language": "en", "nofollow": false, "final_url": "https://liedekerke.com/en", "logo_image": "https://liedekerke.com/img/certification-iso27001.jpg", "open_graph": {"og:url": "https://liedekerke.com/en", "og:image": "https://liedekerke.com/storage/files/4906e45c-85ec-49ec-8c6c-2f9ba6f7a8a6/og_image_liedekerke-logo-black-rgb.png", "og:title": "Liedekerke - Solid International Service Capability", "og:description": "Founded in 1965 by lawyers committed to legal excellence, Liedekerke is an independent law firm recognized for its leadership and expertise."}, "forms_count": 2, "robots_meta": null, "status_code": 200, "content_type": "text/html; charset=UTF-8", "images_count": 18, "social_links": {"tiktok": [], "youtube": ["https://www.youtube.com/channel/UCyld0vG4etibMd8iSP4EoyQ/videos"], "facebook": ["https://www.facebook.com/LWWKLAW"], "linkedin": ["https://be.linkedin.com/company/liedekerke-wolters-waelbroeck-kirkpatrick"], "instagram": ["https://www.instagram.com/liedekerkelaw"], "x_twitter": []}, "title_exists": true, "title_length": 64, "twitter_card": {"twitter:card": null, "twitter:image": null, "twitter:title": null, "twitter:description": null}, "canonical_url": "https://liedekerke.com/en", "error_message": null, "footer_exists": true, "meta_keywords": null, "redirect_count": 1, "robots_txt_url": "https://liedekerke.com/robots.txt", "images_with_alt": 18, "sitemap_xml_url": "https://liedekerke.com/sitemap.xml", "meta_description": "Founded in 1965 by lawyers committed to legal excellence, Liedekerke is an independent law firm recognized for its leadership and expertise.", "schema_org_types": ["Organization", "WebSite"], "technology_hints": {"wix": false, "shopify": false, "wordpress": false, "google_analytics": false, "google_tag_manager": true}, "about_page_exists": true, "canonical_present": true, "images_without_alt": 0, "open_graph_present": true, "contact_page_exists": true, "schema_org_detected": true, "external_links_count": 6, "internal_links_count": 72, "meta_keywords_exists": false, "robots_txt_available": true, "twitter_card_present": false, "sitemap_xml_available": true, "navigation_links_count": 59, "meta_description_exists": true, "meta_description_length": 140}	NORMALIZED	curated-demo-be-law-office-liedekerke-brussels:WEBSITE:website:68	2026-06-29 15:10:52.71111
\.


--
-- Name: lead_analysis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lead_analysis_id_seq', 65, true);


--
-- Name: lead_axis_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lead_axis_scores_id_seq', 350, true);


--
-- Name: lead_contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lead_contacts_id_seq', 24, true);


--
-- Name: lead_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lead_scores_id_seq', 137, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 4, true);


--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.scraping_jobs_id_seq', 69, true);


--
-- Name: scraping_raw_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.scraping_raw_results_id_seq', 58, true);


--
-- Name: leads PK_278eae726654eb05e5bf3323d6d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT "PK_278eae726654eb05e5bf3323d6d" PRIMARY KEY (google_place_id);


--
-- Name: lead_scores PK_2b746fdae1c91da0baa4d2c0bbb; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_scores
    ADD CONSTRAINT "PK_2b746fdae1c91da0baa4d2c0bbb" PRIMARY KEY (id);


--
-- Name: lead_axis_scores PK_362edab059b64180bb476c02ee2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_axis_scores
    ADD CONSTRAINT "PK_362edab059b64180bb476c02ee2" PRIMARY KEY (id);


--
-- Name: lead_analysis PK_721e421d81dadd7b1e049ea1251; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_analysis
    ADD CONSTRAINT "PK_721e421d81dadd7b1e049ea1251" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: lead_contacts PK_dcbc274112e03d83ed9020c70b1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_contacts
    ADD CONSTRAINT "PK_dcbc274112e03d83ed9020c70b1" PRIMARY KEY (id);


--
-- Name: scraping_jobs PK_ea8bda4d31fb254e7c7cf079a19; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_jobs
    ADD CONSTRAINT "PK_ea8bda4d31fb254e7c7cf079a19" PRIMARY KEY (id);


--
-- Name: scraping_raw_results PK_f21949e764fa45e3b2f57a568e9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_raw_results
    ADD CONSTRAINT "PK_f21949e764fa45e3b2f57a568e9" PRIMARY KEY (id);


--
-- Name: IDX_lead_analysis_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_analysis_lead_id" ON public.lead_analysis USING btree (lead_id);


--
-- Name: IDX_lead_axis_scores_analysis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_axis_scores_analysis_id" ON public.lead_axis_scores USING btree (analysis_id);


--
-- Name: IDX_lead_axis_scores_axis; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_axis_scores_axis" ON public.lead_axis_scores USING btree (axis);


--
-- Name: IDX_lead_axis_scores_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_axis_scores_lead_id" ON public.lead_axis_scores USING btree (lead_id);


--
-- Name: IDX_lead_axis_scores_score_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_axis_scores_score_type" ON public.lead_axis_scores USING btree (score_type);


--
-- Name: IDX_lead_contacts_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_contacts_lead_id" ON public.lead_contacts USING btree (lead_id);


--
-- Name: IDX_lead_scores_analysis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_scores_analysis_id" ON public.lead_scores USING btree (analysis_id);


--
-- Name: IDX_lead_scores_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_scores_lead_id" ON public.lead_scores USING btree (lead_id);


--
-- Name: IDX_lead_scores_period_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_lead_scores_period_type" ON public.lead_scores USING btree (period_type);


--
-- Name: IDX_scraping_jobs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_jobs_created_at" ON public.scraping_jobs USING btree (created_at);


--
-- Name: IDX_scraping_jobs_job_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_jobs_job_type" ON public.scraping_jobs USING btree (job_type);


--
-- Name: IDX_scraping_jobs_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_jobs_lead_id" ON public.scraping_jobs USING btree (lead_id);


--
-- Name: IDX_scraping_jobs_lead_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_jobs_lead_id_created_at" ON public.scraping_jobs USING btree (lead_id, created_at);


--
-- Name: IDX_scraping_jobs_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_jobs_status" ON public.scraping_jobs USING btree (status);


--
-- Name: IDX_scraping_raw_results_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_created_at" ON public.scraping_raw_results USING btree (created_at);


--
-- Name: IDX_scraping_raw_results_dedupe_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_dedupe_key" ON public.scraping_raw_results USING btree (dedupe_key);


--
-- Name: IDX_scraping_raw_results_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_job_id" ON public.scraping_raw_results USING btree (job_id);


--
-- Name: IDX_scraping_raw_results_job_id_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_job_id_source" ON public.scraping_raw_results USING btree (job_id, source);


--
-- Name: IDX_scraping_raw_results_lead_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_lead_id" ON public.scraping_raw_results USING btree (lead_id);


--
-- Name: IDX_scraping_raw_results_lead_id_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_lead_id_source" ON public.scraping_raw_results USING btree (lead_id, source);


--
-- Name: IDX_scraping_raw_results_normalized_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_normalized_status" ON public.scraping_raw_results USING btree (normalized_status);


--
-- Name: IDX_scraping_raw_results_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_scraping_raw_results_source" ON public.scraping_raw_results USING btree (source);


--
-- Name: idx_lead_scores_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lead_scores_date ON public.lead_scores USING btree (lead_id, score_date);


--
-- Name: lead_analysis FK_lead_analysis_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_analysis
    ADD CONSTRAINT "FK_lead_analysis_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- Name: lead_axis_scores FK_lead_axis_scores_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_axis_scores
    ADD CONSTRAINT "FK_lead_axis_scores_analysis_id" FOREIGN KEY (analysis_id) REFERENCES public.lead_analysis(id);


--
-- Name: lead_axis_scores FK_lead_axis_scores_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_axis_scores
    ADD CONSTRAINT "FK_lead_axis_scores_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- Name: lead_contacts FK_lead_contacts_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_contacts
    ADD CONSTRAINT "FK_lead_contacts_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- Name: lead_scores FK_lead_scores_analysis_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_scores
    ADD CONSTRAINT "FK_lead_scores_analysis_id" FOREIGN KEY (analysis_id) REFERENCES public.lead_analysis(id);


--
-- Name: lead_scores FK_lead_scores_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lead_scores
    ADD CONSTRAINT "FK_lead_scores_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- Name: scraping_jobs FK_scraping_jobs_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_jobs
    ADD CONSTRAINT "FK_scraping_jobs_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- Name: scraping_raw_results FK_scraping_raw_results_job_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_raw_results
    ADD CONSTRAINT "FK_scraping_raw_results_job_id" FOREIGN KEY (job_id) REFERENCES public.scraping_jobs(id);


--
-- Name: scraping_raw_results FK_scraping_raw_results_lead_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scraping_raw_results
    ADD CONSTRAINT "FK_scraping_raw_results_lead_id" FOREIGN KEY (lead_id) REFERENCES public.leads(google_place_id);


--
-- PostgreSQL database dump complete
--

\unrestrict KAIBQIpn4F6E6awZUnGTR7nQZeMvX8JIsK3xTurDmIbwCQVbrvcZtDghbvjUHJS

