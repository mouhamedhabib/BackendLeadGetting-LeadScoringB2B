export type PlacesProviderPlace = {
  id: string;
  displayName: { text: string };
  formattedAddress: string;
  nationalPhoneNumber?: string;
  websiteUri?: string;
  rating: number;
  userRatingCount: number;
  location: {
    latitude: number;
    longitude: number;
  };
};

type CuratedPlace = PlacesProviderPlace & {
  categories: string[];
  markets: string[];
  keywords: string[];
};

const CURATED_PLACES: CuratedPlace[] = [
  {
    id: 'curated-demo-tn-bakery-medina-tunis',
    displayName: { text: 'مخبزة المدينة - Boulangerie Medina' },
    formattedAddress: '18 Rue de Marseille, 1001 Tunis, Tunisia',
    nationalPhoneNumber: '+216 71 256 418',
    websiteUri: 'https://www.paul.fr',
    rating: 4.5,
    userRatingCount: 214,
    location: { latitude: 36.7992, longitude: 10.1815 },
    categories: ['bakery'],
    markets: ['tunisia', 'tunis'],
    keywords: ['bakery', 'boulangerie', 'patisserie', 'tunis', 'tunisia'],
  },
  {
    id: 'curated-demo-fr-bakery-poilane-paris',
    displayName: { text: 'Poilane Saint-Germain' },
    formattedAddress: '8 Rue du Cherche-Midi, 75006 Paris, France',
    nationalPhoneNumber: '+33 1 45 48 42 59',
    websiteUri: 'https://www.poilane.com',
    rating: 4.7,
    userRatingCount: 1420,
    location: { latitude: 48.8507, longitude: 2.3268 },
    categories: ['bakery'],
    markets: ['france', 'paris'],
    keywords: ['bakery', 'boulangerie', 'patisserie', 'paris', 'france'],
  },
  {
    id: 'curated-demo-tn-restaurant-dar-sahel-sousse',
    displayName: { text: 'Dar Sahel Restaurant' },
    formattedAddress: 'Avenue Hedi Chaker, 4000 Sousse, Tunisia',
    nationalPhoneNumber: '+216 73 224 680',
    rating: 4.3,
    userRatingCount: 186,
    location: { latitude: 35.8256, longitude: 10.6369 },
    categories: ['restaurant'],
    markets: ['tunisia', 'sousse'],
    keywords: ['restaurant', 'sousse', 'sahel', 'tunisia'],
  },
  {
    id: 'curated-demo-fr-restaurant-septime-paris',
    displayName: { text: 'Septime Paris' },
    formattedAddress: '80 Rue de Charonne, 75011 Paris, France',
    nationalPhoneNumber: '+33 1 43 67 38 29',
    websiteUri: 'https://www.septime-charonne.fr',
    rating: 4.6,
    userRatingCount: 1384,
    location: { latitude: 48.8537, longitude: 2.3816 },
    categories: ['restaurant'],
    markets: ['france', 'paris'],
    keywords: ['restaurant', 'paris', 'france', 'bistrot'],
  },
  {
    id: 'curated-demo-tn-hotel-la-badira-hammamet',
    displayName: { text: 'La Badira Hammamet' },
    formattedAddress: 'BP 437, 8050 Hammamet, Tunisia',
    nationalPhoneNumber: '+216 70 018 180',
    websiteUri: 'https://www.labadira.com',
    rating: 4.7,
    userRatingCount: 2610,
    location: { latitude: 36.4081, longitude: 10.6482 },
    categories: ['hotel'],
    markets: ['tunisia', 'hammamet'],
    keywords: ['hotel', 'hammamet', 'tunisia', 'resort', 'spa'],
  },
  {
    id: 'curated-demo-fr-hotel-accor-paris-montparnasse',
    displayName: { text: 'Hotel Mercure Paris Montparnasse Raspail' },
    formattedAddress: '207 Boulevard Raspail, 75014 Paris, France',
    nationalPhoneNumber: '+33 1 43 20 62 94',
    websiteUri: 'https://www.accor.com',
    rating: 4.2,
    userRatingCount: 962,
    location: { latitude: 48.8404, longitude: 2.3291 },
    categories: ['hotel'],
    markets: ['france', 'paris'],
    keywords: ['hotel', 'paris', 'france', 'montparnasse'],
  },
  {
    id: 'curated-demo-tn-dental-clinic-sourire-sousse',
    displayName: { text: 'Clinique Dentaire Sourire du Sahel' },
    formattedAddress: 'Boulevard du 14 Janvier, 4039 Sousse, Tunisia',
    nationalPhoneNumber: '+216 73 822 410',
    websiteUri: 'https://www.doctolib.fr',
    rating: 4.8,
    userRatingCount: 127,
    location: { latitude: 35.8291, longitude: 10.6407 },
    categories: ['dental clinic'],
    markets: ['tunisia', 'sousse'],
    keywords: ['dentist', 'dental', 'dentiste', 'clinic', 'clinique', 'sousse'],
  },
  {
    id: 'curated-demo-fr-dental-clinic-saint-lazare-paris',
    displayName: { text: 'Centre Dentaire Saint-Lazare' },
    formattedAddress: '12 Rue de Londres, 75009 Paris, France',
    nationalPhoneNumber: '+33 1 42 81 44 20',
    websiteUri: 'https://www.doctolib.fr',
    rating: 4.4,
    userRatingCount: 346,
    location: { latitude: 48.8765, longitude: 2.3296 },
    categories: ['dental clinic'],
    markets: ['france', 'paris'],
    keywords: ['dentist', 'dental', 'dentiste', 'clinic', 'france', 'paris'],
  },
  {
    id: 'curated-demo-tn-digital-agency-kif-lac-tunis',
    displayName: { text: 'Kif Digital Studio' },
    formattedAddress: 'Rue du Lac Malaren, Les Berges du Lac 1, Tunis, Tunisia',
    nationalPhoneNumber: '+216 70 145 880',
    websiteUri: 'https://www.tapptic.com',
    rating: 4.7,
    userRatingCount: 58,
    location: { latitude: 36.8383, longitude: 10.2419 },
    categories: ['digital agency'],
    markets: ['tunisia', 'tunis'],
    keywords: ['agency', 'digital', 'marketing', 'web', 'tunis', 'tunisia'],
  },
  {
    id: 'curated-demo-be-digital-agency-tapptic-brussels',
    displayName: { text: 'Tapptic Brussels' },
    formattedAddress: 'Avenue Louise 523, 1050 Brussels, Belgium',
    nationalPhoneNumber: '+32 2 318 44 72',
    websiteUri: 'https://www.tapptic.com',
    rating: 4.6,
    userRatingCount: 74,
    location: { latitude: 50.8162, longitude: 4.3687 },
    categories: ['digital agency'],
    markets: ['belgium', 'brussels'],
    keywords: ['agency', 'digital', 'marketing', 'web', 'belgium', 'brussels'],
  },
  {
    id: 'curated-demo-tn-real-estate-mubawab-tunis',
    displayName: { text: 'Mubawab Tunisie Immobilier' },
    formattedAddress:
      'Immeuble Golden Towers, Centre Urbain Nord, Tunis, Tunisia',
    nationalPhoneNumber: '+216 70 029 240',
    websiteUri: 'https://www.mubawab.tn',
    rating: 4.1,
    userRatingCount: 239,
    location: { latitude: 36.8452, longitude: 10.2019 },
    categories: ['real estate agency'],
    markets: ['tunisia', 'tunis'],
    keywords: [
      'real estate',
      'immobilier',
      'agency',
      'immo',
      'tunis',
      'tunisia',
    ],
  },
  {
    id: 'curated-demo-be-real-estate-century21-brussels',
    displayName: { text: 'Century 21 Brussels South' },
    formattedAddress: 'Chaussee de Waterloo 715, 1180 Uccle, Belgium',
    nationalPhoneNumber: '+32 2 343 22 40',
    websiteUri: 'https://www.century21.be',
    rating: 4.0,
    userRatingCount: 118,
    location: { latitude: 50.8088, longitude: 4.3642 },
    categories: ['real estate agency'],
    markets: ['belgium', 'brussels'],
    keywords: [
      'real estate',
      'immobilier',
      'immo',
      'agency',
      'belgium',
      'brussels',
    ],
  },
  {
    id: 'curated-demo-tn-plumber-hydrotek-tunis',
    displayName: { text: 'Hydrotek Plomberie Tunis' },
    formattedAddress: 'Avenue Hedi Nouira, 2037 Ariana, Tunisia',
    nationalPhoneNumber: '+216 71 702 944',
    rating: 4.2,
    userRatingCount: 43,
    location: { latitude: 36.8625, longitude: 10.1956 },
    categories: ['plumber'],
    markets: ['tunisia', 'tunis', 'ariana'],
    keywords: ['plumber', 'plomberie', 'tunis', 'ariana', 'tunisia'],
  },
  {
    id: 'curated-demo-be-plumber-facq-brussels',
    displayName: { text: 'FACQ Brussels Plumbing Showroom' },
    formattedAddress: 'Rue de Birmingham 112, 1070 Brussels, Belgium',
    nationalPhoneNumber: '+32 2 558 29 11',
    websiteUri: 'https://www.facq.be',
    rating: 4.1,
    userRatingCount: 312,
    location: { latitude: 50.8434, longitude: 4.3226 },
    categories: ['plumber'],
    markets: ['belgium', 'brussels'],
    keywords: ['plumber', 'plombier', 'plomberie', 'belgium', 'brussels'],
  },
  {
    id: 'curated-demo-tn-beauty-salon-nour-sfax',
    displayName: { text: 'صالون نور - Salon Nour Beaute' },
    formattedAddress: 'Route de Gremda km 2, 3000 Sfax, Tunisia',
    nationalPhoneNumber: '+216 74 402 118',
    rating: 4.0,
    userRatingCount: 58,
    location: { latitude: 34.7486, longitude: 10.7553 },
    categories: ['beauty salon'],
    markets: ['tunisia', 'sfax'],
    keywords: ['beauty', 'salon', 'coiffure', 'beaute', 'sfax', 'tunisia'],
  },
  {
    id: 'curated-demo-fr-beauty-salon-dessange-paris',
    displayName: { text: 'Dessange Paris Madeleine' },
    formattedAddress: '4 Rue du Faubourg Saint-Honore, 75008 Paris, France',
    nationalPhoneNumber: '+33 1 42 65 08 05',
    websiteUri: 'https://www.dessange.com',
    rating: 4.3,
    userRatingCount: 221,
    location: { latitude: 48.8682, longitude: 2.3222 },
    categories: ['beauty salon'],
    markets: ['france', 'paris'],
    keywords: ['beauty', 'salon', 'coiffure', 'beaute', 'paris', 'france'],
  },
  {
    id: 'curated-demo-tn-car-repair-carthage-auto-ariana',
    displayName: { text: 'Garage Carthage Auto' },
    formattedAddress: 'Rue de l Industrie, 2080 Ariana, Tunisia',
    nationalPhoneNumber: '+216 71 706 219',
    rating: 4.3,
    userRatingCount: 102,
    location: { latitude: 36.8611, longitude: 10.1938 },
    categories: ['car repair'],
    markets: ['tunisia', 'ariana', 'tunis'],
    keywords: ['car repair', 'garage', 'auto', 'mechanic', 'tunis', 'ariana'],
  },
  {
    id: 'curated-demo-fr-car-repair-norauto-lyon',
    displayName: { text: 'Norauto Lyon Bron' },
    formattedAddress: '209 Avenue Franklin Roosevelt, 69500 Bron, France',
    nationalPhoneNumber: '+33 4 72 37 80 80',
    websiteUri: 'https://www.norauto.fr',
    rating: 4.0,
    userRatingCount: 684,
    location: { latitude: 45.7338, longitude: 4.9132 },
    categories: ['car repair'],
    markets: ['france', 'lyon'],
    keywords: ['car repair', 'garage', 'auto', 'mechanic', 'france', 'lyon'],
  },
  {
    id: 'curated-demo-tn-law-office-ferchiou-tunis',
    displayName: { text: 'Ferchiou & Associes' },
    formattedAddress: 'Rue du Lac Lochness, Les Berges du Lac, Tunis, Tunisia',
    nationalPhoneNumber: '+216 71 965 620',
    websiteUri: 'https://www.ferchioulaw.com',
    rating: 4.5,
    userRatingCount: 31,
    location: { latitude: 36.8439, longitude: 10.2673 },
    categories: ['law office'],
    markets: ['tunisia', 'tunis'],
    keywords: ['law', 'lawyer', 'avocat', 'cabinet', 'tunis', 'tunisia'],
  },
  {
    id: 'curated-demo-be-law-office-liedekerke-brussels',
    displayName: { text: 'Liedekerke Brussels' },
    formattedAddress: 'Boulevard de l Empereur 3, 1000 Brussels, Belgium',
    nationalPhoneNumber: '+32 2 551 15 15',
    websiteUri: 'https://liedekerke.com',
    rating: 4.6,
    userRatingCount: 44,
    location: { latitude: 50.8458, longitude: 4.3547 },
    categories: ['law office'],
    markets: ['belgium', 'brussels'],
    keywords: ['law', 'lawyer', 'avocat', 'cabinet', 'belgium', 'brussels'],
  },
];

const FALLBACK_RESULT_COUNT = 6;
const MARKET_TOKENS = [
  'tunisia',
  'tunis',
  'ariana',
  'sousse',
  'sfax',
  'hammamet',
  'france',
  'paris',
  'lyon',
  'belgium',
  'belgique',
  'brussels',
  'bruxelles',
  'uccle',
];

export function getCuratedPlacesCount(): number {
  return CURATED_PLACES.length;
}

export function searchCuratedPlaces(query: string): PlacesProviderPlace[] {
  const tokens = tokenize(query);
  const requestedMarkets = tokens.filter((token) =>
    MARKET_TOKENS.includes(token),
  );
  const marketFilteredPlaces =
    requestedMarkets.length > 0
      ? CURATED_PLACES.filter((place) =>
          place.markets.some((market) =>
            requestedMarkets.some((token) => normalize(market).includes(token)),
          ),
        )
      : CURATED_PLACES;
  const scored = marketFilteredPlaces
    .map((place, index) => ({
      place,
      index,
      score: scorePlace(place, tokens),
    }))
    .filter((entry) => entry.score > 0);
  const minimumScore = scored.some((entry) => entry.score >= 4) ? 4 : 1;
  const ranked = scored
    .filter((entry) => entry.score >= minimumScore)
    .sort((left, right) => right.score - left.score || left.index - right.index)
    .map((entry) => entry.place);

  const matches =
    ranked.length > 0 ? ranked : fallbackPlaces(query, marketFilteredPlaces);

  return matches.map(({ categories, markets, keywords, ...place }) => place);
}

function scorePlace(place: CuratedPlace, tokens: string[]): number {
  const searchableValues = [
    place.displayName.text,
    place.formattedAddress,
    ...place.categories,
    ...place.markets,
    ...place.keywords,
  ].map(normalize);

  return tokens.reduce((score, token) => {
    const matchedValue = searchableValues.find((value) =>
      value.includes(token),
    );
    if (!matchedValue) {
      return score;
    }

    if (
      place.categories.some((category) => normalize(category).includes(token))
    ) {
      return score + 4;
    }

    if (place.markets.some((market) => normalize(market).includes(token))) {
      return score + 3;
    }

    return score + 1;
  }, 0);
}

function fallbackPlaces(query: string, places: CuratedPlace[]): CuratedPlace[] {
  const source = places.length > 0 ? places : CURATED_PLACES;
  const start = stableHash(query) % source.length;
  return Array.from({ length: FALLBACK_RESULT_COUNT }, (_, offset) => {
    const index = (start + offset) % source.length;
    return source[index];
  });
}

function tokenize(query: string): string[] {
  return normalize(query)
    .split(/\s+/)
    .filter((token) => token.length >= 2);
}

function normalize(value: string): string {
  return value
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase();
}

function stableHash(value: string): number {
  return normalize(value)
    .split('')
    .reduce((hash, char) => (hash * 31 + char.charCodeAt(0)) >>> 0, 0);
}
