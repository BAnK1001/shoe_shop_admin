import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shoes_shop_admin/controllers/product_controller.dart';
import 'package:shoes_shop_admin/views/main/products/product_detail.dart';
import 'package:shoes_shop_admin/views/widgets/loading_widget.dart';
import '../../../constants/color.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _productStream;
  final ProductController _productController = ProductController();

  @override
  void initState() {
    super.initState();
    _productStream = _productController.getProductStream('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.shopping_bag),
              const SizedBox(width: 10),
              Text(
                'Products',
                style:
                    getMediumStyle(color: Colors.black, fontSize: FontSize.s16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _productStream = _productController.getProductStream('');
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _productStream = _productController.getProductStream(value);
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error occurred!'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingWidget());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Image.asset(AssetManager.noImagePlaceholderImg));
                }

                List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
                sortedDocs
                    .sort((a, b) => b['uploadDate'].compareTo(a['uploadDate']));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    var item = sortedDocs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['imgUrls'][0],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item['productName'],
                          style: getMediumStyle(
                              color: Colors.black, fontSize: FontSize.s16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${item['price']}',
                              style: getMediumStyle(
                                  color: Colors.black, fontSize: FontSize.s14),
                            ),
                            Text(
                              'Quantity: ${item['quantity']}',
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                            Text(
                              intl.DateFormat.yMMMEd()
                                  .format(item['uploadDate'].toDate()),
                              style: getRegularStyle(
                                  color: Colors.black54,
                                  fontSize: FontSize.s12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: item['isApproved']
                                    ? primaryColor
                                    : accentColor,
                              ),
                              onPressed: () =>
                                  _productController.toggleApproval(
                                      item['prodId'], item['isApproved']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _productController
                                  .showDeleteDialog(context, item['prodId'],
                                      deleteAction:
                                          _productController.deleteProduct),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info, color: Colors.blue),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                      productId: item['prodId']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
