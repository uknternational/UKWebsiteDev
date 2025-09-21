import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../products/product_repository.dart';
import 'admin_product_bloc.dart';
import 'coupon_repository.dart';
import 'admin_coupon_bloc.dart';
import 'carousel_repository.dart';
import 'offer_repository.dart';
import 'review_repository.dart';
import 'about_us_repository.dart';
import '../../models/product_model.dart';
import '../../models/coupon_model.dart';
import '../../models/carousel_image_model.dart';
import '../../models/offer_model.dart';
import '../../models/customer_review_model.dart';
import '../../models/about_us_model.dart';
import '../../services/storage_service.dart';
import '../../core/config/environment.dart';
import 'package:url_launcher/url_launcher.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    EnvironmentConfig.initialize(Environment.staging);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AdminProductBloc(ProductRepository())..add(LoadAdminProducts()),
        ),
        BlocProvider(
          create: (_) =>
              AdminCouponBloc(CouponRepository())..add(LoadAdminCoupons()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: const Color(0xFF0C1B33),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Carousel'),
              Tab(text: 'Offers'),
              Tab(text: 'Reviews'),
              Tab(text: 'Coupons'),
              Tab(text: 'About Us'),
              Tab(text: 'Admin Management'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _ProductAdminSection(),
            const _CarouselAdminSection(),
            const _OffersAdminSection(),
            const _ReviewsAdminSection(),
            const _CouponAdminSection(),
            const _AboutUsAdminSection(),
            const _AdminManagementSection(),
          ],
        ),
      ),
    );
  }
}

// Product section with bestseller toggle
class _ProductAdminSection extends StatelessWidget {
  const _ProductAdminSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => _ProductDialog(
                      productBloc: context.read<AdminProductBloc>(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<AdminProductBloc, AdminProductState>(
              builder: (context, state) {
                if (state is AdminProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminProductLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.image_not_supported,
                                              size: 48,
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product.isTopSelling)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'BESTSELLER',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.priceAfterOffer.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => _ProductDialog(
                                          product: product,
                                          productBloc: context
                                              .read<AdminProductBloc>(),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Product'),
                                          content: const Text(
                                            'Are you sure you want to delete this product?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        context.read<AdminProductBloc>().add(
                                          DeleteProduct(product.id),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is AdminProductError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Carousel Images Admin Section
class _CarouselAdminSection extends StatefulWidget {
  const _CarouselAdminSection();

  @override
  State<_CarouselAdminSection> createState() => _CarouselAdminSectionState();
}

class _CarouselAdminSectionState extends State<_CarouselAdminSection> {
  List<CarouselImage> carouselImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final images = await CarouselRepository().fetchAllCarouselImages();
      setState(() {
        carouselImages = images;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Carousel Images',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Image'),
                onPressed: () {
                  _showCarouselImageDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : carouselImages.isEmpty
                ? const Center(child: Text('No carousel images found.'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.0,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: carouselImages.length,
                    itemBuilder: (context, index) {
                      final image = carouselImages[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  image.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                      ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Order: ${image.displayOrder}'),
                                  Row(
                                    children: [
                                      Switch(
                                        value: image.isActive,
                                        onChanged: (value) {
                                          _toggleImageStatus(image, value);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteCarouselImage(image.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCarouselImageDialog([CarouselImage? image]) {
    showDialog(
      context: context,
      builder: (ctx) => _CarouselImageDialog(
        image: image,
        onSaved: () {
          _loadCarouselImages();
        },
      ),
    );
  }

  void _toggleImageStatus(CarouselImage image, bool isActive) async {
    try {
      final updatedImage = image.copyWith(isActive: isActive);
      await CarouselRepository().updateCarouselImage(updatedImage);
      _loadCarouselImages();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating image: $e')));
    }
  }

  void _deleteCarouselImage(String id) async {
    try {
      await CarouselRepository().deleteCarouselImage(id);
      _loadCarouselImages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
    }
  }
}

// Similar sections for Offers and Reviews would be implemented here
// For brevity, I'll create placeholders

class _OffersAdminSection extends StatefulWidget {
  const _OffersAdminSection();

  @override
  State<_OffersAdminSection> createState() => _OffersAdminSectionState();
}

class _OffersAdminSectionState extends State<_OffersAdminSection> {
  List<Offer> offers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final fetchedOffers = await OfferRepository().fetchAllOffers();
      setState(() {
        offers = fetchedOffers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Offers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Offer'),
                onPressed: () {
                  _showOfferDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : offers.isEmpty
                ? const Center(child: Text('No offers found.'))
                : ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: offer.isActive
                                  ? Colors.green[100]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color: offer.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            offer.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(offer.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: offer.isActive,
                                onChanged: (value) {
                                  _toggleOfferStatus(offer, value);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showOfferDialog(offer);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteOffer(offer.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showOfferDialog([Offer? offer]) {
    showDialog(
      context: context,
      builder: (ctx) => _OfferDialog(
        offer: offer,
        onSaved: () {
          _loadOffers();
        },
      ),
    );
  }

  void _toggleOfferStatus(Offer offer, bool isActive) async {
    try {
      final updatedOffer = offer.copyWith(isActive: isActive);
      await OfferRepository().updateOffer(updatedOffer);
      _loadOffers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating offer: $e')));
    }
  }

  void _deleteOffer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offer'),
        content: const Text('Are you sure you want to delete this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await OfferRepository().deleteOffer(id);
        _loadOffers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting offer: $e')));
      }
    }
  }
}

class _ReviewsAdminSection extends StatefulWidget {
  const _ReviewsAdminSection();

  @override
  State<_ReviewsAdminSection> createState() => _ReviewsAdminSectionState();
}

class _ReviewsAdminSectionState extends State<_ReviewsAdminSection> {
  List<CustomerReview> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final fetchedReviews = await ReviewRepository().fetchAllReviews();
      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Review'),
                onPressed: () {
                  _showReviewDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                ? const Center(child: Text('No reviews found.'))
                : ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFA9744F),
                                child: Text(
                                  review.customerName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          review.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: review.isActive
                                                ? Colors.green[100]
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            review.isActive
                                                ? 'Active'
                                                : 'Inactive',
                                            style: TextStyle(
                                              color: review.isActive
                                                  ? Colors.green[700]
                                                  : Colors.grey[600],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          review.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review.reviewText,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    if (review.imageUrl != null) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          review.imageUrl!,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Switch(
                                          value: review.isActive,
                                          onChanged: (value) {
                                            _toggleReviewStatus(review, value);
                                          },
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _showReviewDialog(review);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _deleteReview(review.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog([CustomerReview? review]) {
    showDialog(
      context: context,
      builder: (ctx) => _ReviewDialog(
        review: review,
        onSaved: () {
          _loadReviews();
        },
      ),
    );
  }

  void _toggleReviewStatus(CustomerReview review, bool isActive) async {
    try {
      final updatedReview = review.copyWith(isActive: isActive);
      await ReviewRepository().updateReview(updatedReview);
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating review: $e')));
    }
  }

  void _deleteReview(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ReviewRepository().deleteReview(id);
        _loadReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting review: $e')));
      }
    }
  }
}

class _CouponAdminSection extends StatefulWidget {
  const _CouponAdminSection();

  @override
  State<_CouponAdminSection> createState() => _CouponAdminSectionState();
}

class _CouponAdminSectionState extends State<_CouponAdminSection> {
  List<Coupon> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      final couponList = await CouponRepository().fetchAllCoupons();
      setState(() {
        coupons = couponList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Coupons',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Coupon'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => _CouponDialog(onSaved: _loadCoupons),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : coupons.isEmpty
                ? const Center(child: Text('No coupons found.'))
                : ListView.builder(
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.card_giftcard,
                            color: Color(0xFF0C1B33),
                          ),
                          title: Text(
                            coupon.code,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Discount: ${coupon.discount}%'),
                              Text(
                                'Expires: ${coupon.expiry.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: coupon.expiry.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Status: ${coupon.isActive ? 'Active' : 'Inactive'}',
                                style: TextStyle(
                                  color: coupon.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => _CouponDialog(
                                      coupon: coupon,
                                      onSaved: _loadCoupons,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCoupon(coupon.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _deleteCoupon(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: const Text('Are you sure you want to delete this coupon?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CouponRepository().deleteCoupon(id);
        _loadCoupons();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting coupon: $e')));
      }
    }
  }
}

// Coupon Dialog
class _CouponDialog extends StatefulWidget {
  final Coupon? coupon;
  final VoidCallback onSaved;

  const _CouponDialog({this.coupon, required this.onSaved});

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _discountController;
  late DateTime _expiry;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeController = TextEditingController(text: c?.code ?? '');
    _discountController = TextEditingController(
      text: c?.discount.toString() ?? '',
    );
    _expiry = c?.expiry ?? DateTime.now().add(const Duration(days: 30));
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final coupon = Coupon(
        id:
            widget.coupon?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        code: _codeController.text.trim(),
        discount: double.tryParse(_discountController.text) ?? 0.0,
        expiry: _expiry,
        isActive: _isActive,
        createdAt: widget.coupon?.createdAt ?? now,
      );

      if (widget.coupon == null) {
        CouponRepository().addCoupon(coupon);
      } else {
        CouponRepository().updateCoupon(coupon);
      }
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.coupon == null ? 'Add Coupon' : 'Edit Coupon'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Coupon Code'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount (%)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final discount = double.tryParse(v);
                  if (discount == null || discount < 0 || discount > 100) {
                    return 'Enter a valid percentage (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expiry Date'),
                subtitle: Text('${_expiry.toLocal()}'.split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiry,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _expiry = picked);
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

// Product Dialog with bestseller toggle
class _ProductDialog extends StatefulWidget {
  final Product? product;
  final AdminProductBloc productBloc;
  const _ProductDialog({this.product, required this.productBloc});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _mrpController;
  late final TextEditingController _offerController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _stockController;
  bool _isTopSelling = false;
  String _selectedCategory = 'Premium Perfumes';

  // Available categories
  final List<String> _categories = [
    'Premium Perfumes',
    'Luxury Perfumes',
    'Arabic Perfumes',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _mrpController = TextEditingController(text: p?.mrp.toString() ?? '');
    _offerController = TextEditingController(text: p?.offer.toString() ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _isTopSelling = p?.isTopSelling ?? false;
    _selectedCategory = p?.category ?? 'Premium Perfumes';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _mrpController.dispose();
    _offerController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  double _calculatePriceAfterOffer(double mrp, double offer) {
    return mrp - (mrp * offer / 100);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final mrp = double.tryParse(_mrpController.text) ?? 0.0;
      final offer = double.tryParse(_offerController.text) ?? 0.0;
      final priceAfterOffer = _calculatePriceAfterOffer(mrp, offer);

      final product = Product(
        id:
            widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        mrp: mrp,
        offer: offer,
        priceAfterOffer: priceAfterOffer,
        price: priceAfterOffer,
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        stock: int.tryParse(_stockController.text) ?? 0,
        isTopSelling: _isTopSelling,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.product == null) {
        widget.productBloc.add(AddProduct(product));
      } else {
        widget.productBloc.add(UpdateProduct(product));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _mrpController,
                  decoration: const InputDecoration(labelText: 'MRP'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final mrp = double.tryParse(v);
                    if (mrp == null || mrp <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _offerController,
                  decoration: const InputDecoration(labelText: 'Offer (%)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final offer = double.tryParse(v);
                    if (offer == null || offer < 0 || offer > 100) {
                      return 'Enter a valid percentage (0-100)';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (or upload below)',
                          hintText: 'https://example.com/image.jpg',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Image URL or upload required'
                            : null,
                        onChanged: (value) {
                          // Trigger rebuild to update preview
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Image Upload Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.upload_file, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Or Upload Image',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.cloud_upload),
                        label: Text(
                          _imageUrlController.text.isNotEmpty &&
                                  _imageUrlController.text.contains('supabase')
                              ? 'Change Uploaded Image'
                              : 'Upload Image',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _imageUrlController.text.isNotEmpty &&
                                  _imageUrlController.text.contains('supabase')
                              ? Colors.orange
                              : const Color(0xFF0C1B33),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_imageUrlController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _imageUrlController.text.contains('supabase')
                                      ? 'Image uploaded successfully'
                                      : 'Image URL provided',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.red[600],
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imageUrlController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Image Preview Section
                if (_imageUrlController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.preview, color: Colors.blue[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Image Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _isValidImageUrl(_imageUrlController.text)
                                ? Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Loading image...',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildErrorWidget(),
                                  )
                                : _buildErrorWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final stock = int.tryParse(v);
                    if (stock == null || stock < 0)
                      return 'Enter a valid stock';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SwitchListTile(
                  title: const Text('Mark as Bestseller'),
                  value: _isTopSelling,
                  onChanged: (value) {
                    setState(() {
                      _isTopSelling = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  void _uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Uploading image...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        final Uint8List imageData = await image.readAsBytes();
        final String fileName =
            'carousel_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String imageUrl = await StorageService().uploadCarouselImage(
          imageData,
          fileName,
        );

        setState(() {
          _imageUrlController.text = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) return false;

      // Check if it's a common image format
      final imageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.svg',
      ];
      final hasImageExtension = imageExtensions.any(
        (ext) => url.toLowerCase().contains(ext),
      );

      // If it's a Supabase URL, it's likely valid
      if (url.contains('supabase')) return true;

      // For other URLs, check if they have image extensions
      return hasImageExtension;
    } catch (e) {
      return false;
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 40),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Check URL or upload a new image',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Carousel Image Dialog
class _CarouselImageDialog extends StatefulWidget {
  final CarouselImage? image;
  final VoidCallback onSaved;

  const _CarouselImageDialog({this.image, required this.onSaved});

  @override
  State<_CarouselImageDialog> createState() => _CarouselImageDialogState();
}

class _CarouselImageDialogState extends State<_CarouselImageDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayOrderController;
  String? _imageUrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _displayOrderController = TextEditingController(
      text: widget.image?.displayOrder.toString() ?? '1',
    );
    _imageUrl = widget.image?.imageUrl;
    _isActive = widget.image?.isActive ?? true;
  }

  @override
  void dispose() {
    _displayOrderController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _imageUrl != null) {
      try {
        final carouselImage = CarouselImage(
          id:
              widget.image?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: _imageUrl!,
          isActive: _isActive,
          displayOrder: int.tryParse(_displayOrderController.text) ?? 1,
          createdAt: widget.image?.createdAt ?? DateTime.now(),
        );

        if (widget.image == null) {
          await CarouselRepository().addCarouselImage(carouselImage);
        } else {
          await CarouselRepository().updateCarouselImage(carouselImage);
        }

        widget.onSaved();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carousel image saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  void _uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final Uint8List imageData = await image.readAsBytes();
        final String fileName =
            'carousel_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String imageUrl = await StorageService().uploadCarouselImage(
          imageData,
          fileName,
        );

        setState(() {
          _imageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.image == null ? 'Add Carousel Image' : 'Edit Carousel Image',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_imageUrl != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Image uploaded successfully',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red[600], size: 18),
                      onPressed: () {
                        setState(() {
                          _imageUrl = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.upload),
              label: Text(_imageUrl == null ? 'Upload Image' : 'Change Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C1B33),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayOrderController,
              decoration: const InputDecoration(labelText: 'Display Order'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final order = int.tryParse(v);
                if (order == null || order < 1) return 'Enter a valid order';
                return null;
              },
            ),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _imageUrl != null ? _submit : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Offer Dialog
class _OfferDialog extends StatefulWidget {
  final Offer? offer;
  final VoidCallback onSaved;

  const _OfferDialog({this.offer, required this.onSaved});

  @override
  State<_OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<_OfferDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.offer?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.offer?.description ?? '',
    );
    _isActive = widget.offer?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final offer = Offer(
          id:
              widget.offer?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          isActive: _isActive,
          createdAt: widget.offer?.createdAt ?? DateTime.now(),
        );

        if (widget.offer == null) {
          await OfferRepository().addOffer(offer);
        } else {
          await OfferRepository().updateOffer(offer);
        }

        widget.onSaved();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving offer: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.offer == null ? 'Add Offer' : 'Edit Offer'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

// Review Dialog
class _ReviewDialog extends StatefulWidget {
  final CustomerReview? review;
  final VoidCallback onSaved;

  const _ReviewDialog({this.review, required this.onSaved});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerNameController;
  late final TextEditingController _reviewTextController;
  double _rating = 5.0;
  String? _imageUrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.review?.customerName ?? '',
    );
    _reviewTextController = TextEditingController(
      text: widget.review?.reviewText ?? '',
    );
    _rating = widget.review?.rating ?? 5.0;
    _imageUrl = widget.review?.imageUrl;
    _isActive = widget.review?.isActive ?? true;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _reviewTextController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final review = CustomerReview(
          id:
              widget.review?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          customerName: _customerNameController.text.trim(),
          reviewText: _reviewTextController.text.trim(),
          rating: _rating,
          imageUrl: _imageUrl,
          isActive: _isActive,
          createdAt: widget.review?.createdAt ?? DateTime.now(),
        );

        if (widget.review == null) {
          await ReviewRepository().addReview(review);
        } else {
          await ReviewRepository().updateReview(review);
        }

        widget.onSaved();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving review: $e')));
      }
    }
  }

  void _uploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final Uint8List imageData = await image.readAsBytes();
        final String fileName =
            'review_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String imageUrl = await StorageService().uploadReviewImage(
          imageData,
          fileName,
        );

        setState(() {
          _imageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.review == null ? 'Add Review' : 'Edit Review'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewTextController,
                  decoration: const InputDecoration(labelText: 'Review Text'),
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Rating: '),
                    Expanded(
                      child: Slider(
                        value: _rating,
                        min: 1.0,
                        max: 5.0,
                        divisions: 8,
                        label: _rating.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ),
                    Text(_rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_imageUrl != null) ...[
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(_imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadImage,
                        icon: const Icon(Icons.upload),
                        label: Text(
                          _imageUrl == null ? 'Upload Image' : 'Change Image',
                        ),
                      ),
                    ),
                    if (_imageUrl != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _imageUrl = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

// About Us Admin Section
class _AboutUsAdminSection extends StatefulWidget {
  const _AboutUsAdminSection();

  @override
  State<_AboutUsAdminSection> createState() => _AboutUsAdminSectionState();
}

class _AboutUsAdminSectionState extends State<_AboutUsAdminSection> {
  List<AboutUsContent> aboutUsContents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAboutUsContents();
  }

  Future<void> _loadAboutUsContents() async {
    try {
      final contents = await AboutUsRepository().fetchAllAboutUsContent();
      setState(() {
        aboutUsContents = contents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'About Us Content',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Content'),
                onPressed: () {
                  _showAboutUsDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : aboutUsContents.isEmpty
                ? const Center(child: Text('No about us content found.'))
                : ListView.builder(
                    itemCount: aboutUsContents.length,
                    itemBuilder: (context, index) {
                      final content = aboutUsContents[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          content.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          content.subtitle,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: content.isActive
                                          ? Colors.green[100]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      content.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: content.isActive
                                            ? Colors.green[700]
                                            : Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                content.mainDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Switch(
                                    value: content.isActive,
                                    onChanged: (value) {
                                      _toggleContentStatus(content, value);
                                    },
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showAboutUsDialog(content);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _deleteAboutUsContent(content.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAboutUsDialog([AboutUsContent? content]) {
    showDialog(
      context: context,
      builder: (ctx) => _AboutUsDialog(
        content: content,
        onSaved: () {
          _loadAboutUsContents();
        },
      ),
    );
  }

  void _toggleContentStatus(AboutUsContent content, bool isActive) async {
    try {
      final updatedContent = content.copyWith(isActive: isActive);
      await AboutUsRepository().updateAboutUsContent(updatedContent);
      _loadAboutUsContents();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating content: $e')));
    }
  }

  void _deleteAboutUsContent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete About Us Content'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AboutUsRepository().deleteAboutUsContent(id);
        _loadAboutUsContents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting content: $e')));
      }
    }
  }
}

// About Us Dialog
class _AboutUsDialog extends StatefulWidget {
  final AboutUsContent? content;
  final VoidCallback onSaved;

  const _AboutUsDialog({this.content, required this.onSaved});

  @override
  State<_AboutUsDialog> createState() => _AboutUsDialogState();
}

class _AboutUsDialogState extends State<_AboutUsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _mainDescriptionController;
  late final TextEditingController _missionController;
  late final TextEditingController _visionController;
  late final TextEditingController _valuesController;
  late final TextEditingController _heroImageUrlController;
  late final TextEditingController _teamImageUrlController;
  late final TextEditingController _featuresController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final c = widget.content;
    _titleController = TextEditingController(text: c?.title ?? '');
    _subtitleController = TextEditingController(text: c?.subtitle ?? '');
    _mainDescriptionController = TextEditingController(
      text: c?.mainDescription ?? '',
    );
    _missionController = TextEditingController(text: c?.mission ?? '');
    _visionController = TextEditingController(text: c?.vision ?? '');
    _valuesController = TextEditingController(text: c?.values ?? '');
    _heroImageUrlController = TextEditingController(
      text: c?.heroImageUrl ?? '',
    );
    _teamImageUrlController = TextEditingController(
      text: c?.teamImageUrl ?? '',
    );
    _featuresController = TextEditingController(
      text: c?.features.join('\n') ?? '',
    );
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _mainDescriptionController.dispose();
    _missionController.dispose();
    _visionController.dispose();
    _valuesController.dispose();
    _heroImageUrlController.dispose();
    _teamImageUrlController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final features = _featuresController.text
            .split('\n')
            .where((feature) => feature.trim().isNotEmpty)
            .map((feature) => feature.trim())
            .toList();

        final content = AboutUsContent(
          id:
              widget.content?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          subtitle: _subtitleController.text.trim(),
          mainDescription: _mainDescriptionController.text.trim(),
          mission: _missionController.text.trim(),
          vision: _visionController.text.trim(),
          values: _valuesController.text.trim(),
          heroImageUrl: _heroImageUrlController.text.trim(),
          teamImageUrl: _teamImageUrlController.text.trim(),
          features: features,
          isActive: _isActive,
          createdAt: widget.content?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.content == null) {
          await AboutUsRepository().addAboutUsContent(content);
        } else {
          await AboutUsRepository().updateAboutUsContent(content);
        }

        widget.onSaved();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('About Us content saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving content: $e')));
      }
    }
  }

  void _uploadHeroImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Uploading image...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        final Uint8List imageData = await image.readAsBytes();
        final String fileName =
            'aboutus_hero_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String imageUrl = await StorageService().uploadCarouselImage(
          imageData,
          fileName,
        );
        setState(() {
          _heroImageUrlController.text = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _uploadTeamImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Uploading image...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        final Uint8List imageData = await image.readAsBytes();
        final String fileName =
            'aboutus_team_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String imageUrl = await StorageService().uploadCarouselImage(
          imageData,
          fileName,
        );
        setState(() {
          _teamImageUrlController.text = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) return false;
      final imageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.svg',
      ];
      final hasImageExtension = imageExtensions.any(
        (ext) => url.toLowerCase().contains(ext),
      );
      if (url.contains('supabase')) return true;
      return hasImageExtension;
    } catch (e) {
      return false;
    }
  }

  Widget _buildImagePreview(String url, VoidCallback onClear) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 60,
              height: 60,
              child: _isValidImageUrl(url)
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              url.contains('supabase')
                  ? 'Image uploaded'
                  : 'Image URL provided',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red, size: 18),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.content == null
            ? 'Add About Us Content'
            : 'Edit About Us Content',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(labelText: 'Subtitle'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mainDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Main Description',
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _missionController,
                  decoration: const InputDecoration(labelText: 'Mission'),
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _visionController,
                  decoration: const InputDecoration(labelText: 'Vision'),
                  maxLines: 2,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuesController,
                  decoration: const InputDecoration(labelText: 'Values'),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heroImageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Hero Image URL (or upload below)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(
                  _heroImageUrlController.text,
                  () => setState(() => _heroImageUrlController.clear()),
                ),
                ElevatedButton.icon(
                  onPressed: _uploadHeroImage,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    _heroImageUrlController.text.isNotEmpty &&
                            _heroImageUrlController.text.contains('supabase')
                        ? 'Change Uploaded Image'
                        : 'Upload Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _heroImageUrlController.text.isNotEmpty &&
                            _heroImageUrlController.text.contains('supabase')
                        ? Colors.orange
                        : const Color(0xFF0C1B33),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teamImageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Team/Vision Image URL (or upload below)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(
                  _teamImageUrlController.text,
                  () => setState(() => _teamImageUrlController.clear()),
                ),
                ElevatedButton.icon(
                  onPressed: _uploadTeamImage,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    _teamImageUrlController.text.isNotEmpty &&
                            _teamImageUrlController.text.contains('supabase')
                        ? 'Change Uploaded Image'
                        : 'Upload Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _teamImageUrlController.text.isNotEmpty &&
                            _teamImageUrlController.text.contains('supabase')
                        ? Colors.orange
                        : const Color(0xFF0C1B33),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _featuresController,
                  decoration: const InputDecoration(
                    labelText: 'Features (one per line)',
                    hintText: 'Feature 1\nFeature 2\nFeature 3',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

// Admin Management Section
class _AdminManagementSection extends StatelessWidget {
  const _AdminManagementSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Admin Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Admin User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To create a new admin user:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Go to Supabase dashboard'),
                  const Text('2. Navigate to Authentication → Users'),
                  const Text('3. Click "Add User" or "Invite User"'),
                  const Text('4. Enter email and password'),
                  const Text('5. User can then login to admin dashboard'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open Supabase dashboard link
                      launchUrl(Uri.parse('https://supabase.com/dashboard'));
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Supabase Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
