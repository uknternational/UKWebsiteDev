import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../products/product_repository.dart';
import 'admin_product_bloc.dart';
import 'coupon_repository.dart';
import 'admin_coupon_bloc.dart';
import '../../models/product_model.dart';
import '../../models/coupon_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Coupons'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [_ProductAdminSection(), _CouponAdminSection()],
        ),
      ),
    );
  }
}

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
              Builder(
                builder: (innerContext) => ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  onPressed: () {
                    showDialog(
                      context: innerContext,
                      builder: (ctx) => _ProductDialog(context: innerContext),
                    );
                  },
                ),
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
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '50ml',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${product.offer.toStringAsFixed(0)}% OFF',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₹${product.mrp.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${product.priceAfterOffer.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${product.stock}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Builder(
                                    builder: (innerContext) => IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: innerContext,
                                          builder: (ctx) => _ProductDialog(
                                            context: innerContext,
                                            product: product,
                                          ),
                                        );
                                      },
                                    ),
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

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final BuildContext context;
  const _ProductDialog({this.product, required this.context});
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
  late final TextEditingController _categoryController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _mrpController = TextEditingController(text: p?.mrp.toString() ?? '');
    _offerController = TextEditingController(text: p?.offer.toString() ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _mrpController.dispose();
    _offerController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
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
        price: priceAfterOffer, // Using priceAfterOffer as the display price
        imageUrl: _imageUrlController.text.trim(),
        category: _categoryController.text.trim(),
        stock: int.tryParse(_stockController.text) ?? 0,
        isTopSelling: widget.product?.isTopSelling ?? false,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
      );
      if (widget.product == null) {
        widget.context.read<AdminProductBloc>().add(AddProduct(product));
      } else {
        widget.context.read<AdminProductBloc>().add(UpdateProduct(product));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
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
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final stock = int.tryParse(v);
                  if (stock == null || stock < 0) return 'Enter a valid stock';
                  return null;
                },
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

class _CouponAdminSection extends StatelessWidget {
  const _CouponAdminSection();
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
              Builder(
                builder: (innerContext) => ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Coupon'),
                  onPressed: () {
                    showDialog(
                      context: innerContext,
                      builder: (ctx) => _CouponDialog(context: innerContext),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<AdminCouponBloc, AdminCouponState>(
              builder: (context, state) {
                if (state is AdminCouponLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminCouponLoaded) {
                  if (state.coupons.isEmpty) {
                    return const Center(child: Text('No coupons found.'));
                  }
                  return ListView.separated(
                    itemCount: state.coupons.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final coupon = state.coupons[index];
                      return ListTile(
                        leading: const Icon(Icons.card_giftcard),
                        title: Text(coupon.code),
                        subtitle: Text(
                          'Discount: ${coupon.discount}% | Expires: ${coupon.expiry.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (innerContext) => IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: innerContext,
                                    builder: (ctx) => _CouponDialog(
                                      context: innerContext,
                                      coupon: coupon,
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Coupon'),
                                    content: const Text(
                                      'Are you sure you want to delete this coupon?',
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
                                  context.read<AdminCouponBloc>().add(
                                    DeleteCoupon(coupon.id),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is AdminCouponError) {
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

class _CouponDialog extends StatefulWidget {
  final Coupon? coupon;
  final BuildContext context;
  const _CouponDialog({this.coupon, required this.context});
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
        id: widget.coupon?.id ?? '',
        code: _codeController.text.trim(),
        discount: double.tryParse(_discountController.text) ?? 0.0,
        expiry: _expiry,
        isActive: _isActive,
        createdAt: widget.coupon?.createdAt ?? now,
      );
      if (widget.coupon == null) {
        widget.context.read<AdminCouponBloc>().add(AddCoupon(coupon));
      } else {
        widget.context.read<AdminCouponBloc>().add(UpdateCoupon(coupon));
      }
      Navigator.pop(context);
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
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount (%)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
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
