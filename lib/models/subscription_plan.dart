/// Subscription Plan Model
/// 
/// Defines the 3 subscription tiers for EchoFort
/// MUST match website pricing: ₹399 / ₹799 / ₹1499
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final int priceINR;
  final int priceUSD;
  final String period;
  final List<String> features;
  final bool isPopular;
  final String badge;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceINR,
    required this.priceUSD,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.badge = '',
  });

  String get priceDisplayINR => '₹$priceINR';
  String get priceDisplayUSD => '\$$priceUSD';
}

/// The 3 subscription plans
class SubscriptionPlans {
  static const basic = SubscriptionPlan(
    id: 'basic',
    name: 'Basic',
    description: 'Essential protection for individuals',
    priceINR: 399,
    priceUSD: 5,
    period: 'month',
    features: [
      'AI Call Screening',
      'Scam Detection',
      'Call Blocking',
      'SMS Protection',
      'Scam Database Access',
      'Basic Support',
    ],
  );

  static const personal = SubscriptionPlan(
    id: 'personal',
    name: 'Personal',
    description: 'Advanced protection with premium features',
    priceINR: 799,
    priceUSD: 10,
    period: 'month',
    features: [
      'Everything in Basic',
      'Real-Time Call Analysis',
      'Advanced Threat Detection',
      'Priority Support',
      'Call Recording (30 days)',
      'Detailed Analytics',
      'Custom Block Lists',
    ],
  );

  static const family = SubscriptionPlan(
    id: 'family',
    name: 'Family',
    description: 'Complete protection for your entire family',
    priceINR: 1499,
    priceUSD: 18,
    period: 'month',
    features: [
      'Everything in Personal',
      'Up to 5 Family Members',
      'GPS Location Tracking',
      'Geofencing & Alerts',
      'Family Dashboard',
      'Shared Scam Reports',
      'Emergency SOS',
      'Dedicated Support',
    ],
    isPopular: true,
    badge: 'Most Protection',
  );

  static List<SubscriptionPlan> get all => [basic, personal, family];
}
