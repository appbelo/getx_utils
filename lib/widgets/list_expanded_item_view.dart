import 'package:flutter/material.dart';

class ListExpandedItemView extends StatelessWidget {
  final String id;
  final String name;
  final Widget? leading;
  final ImageProvider<Object>? image;
  final bool hideTrailing;
  final bool hideChildren;

  final ValueChanged<String>? onEdit;
  final ValueChanged<String>? onPayment;

  const ListExpandedItemView(
      {Key? key,
      required this.id,
      required this.name,
      this.onEdit,
      this.onPayment,
      this.leading,
      this.image,
      this.hideTrailing = false,
      this.hideChildren = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: leading ?? CircleAvatar(backgroundImage: image ?? const AssetImage("assets/images/item.webp")),
      title: Text(
        name,
        style: Theme.of(context).textTheme.headline6,
      ),
      tilePadding: const EdgeInsets.all(14.0),
      trailing: hideTrailing
          ? const SizedBox.shrink()
          : SizedBox(
              width: 125,
              child: ButtonBar(
                children: [
                  IconButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      iconSize: 32,
                      onPressed: onEdit != null ? () => onEdit!(id) : null,
                      icon: const Icon(Icons.edit_outlined)),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    iconSize: 32,
                    onPressed: onPayment != null ? () => onPayment!(id) : null,
                    icon: const Icon(Icons.payment_outlined),
                  )
                ],
              ),
            ),
      children: hideChildren
          ? []
          : [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8),
                        height: 70,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                          ),
                          onPressed: onEdit != null ? () => onEdit!(id) : null,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text("Editar"),
                        ),
                      ),
                      Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8),
                        height: 70,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                          ),
                          onPressed: onPayment != null ? () => onPayment!(id) : null,
                          icon: const Icon(Icons.payment_outlined),
                          label: const Text("Pagamentos"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
    );
  }
}
