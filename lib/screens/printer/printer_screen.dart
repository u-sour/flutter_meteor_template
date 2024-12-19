import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:provider/provider.dart';
import '../../providers/printer_provider.dart';
import '../../router/route_utils.dart';
import '../../services/global_service.dart';
import '../../storages/printer_storage.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/printer/printing_progress_widget.dart';

class PrinterScreen extends StatelessWidget {
  final Widget child;
  const PrinterScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    PrinterProvider readProvider = context.read<PrinterProvider>();
    return Scaffold(
        appBar: AppBarWidget(title: SCREENS.printer.toTitle),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Receipt(
                  backgroundColor: Colors.grey.shade200,
                  onInitialized: (controller) async {
                    // check & set printer paper size
                    final PrinterStorage printerStorage = PrinterStorage();
                    final String printerPaperSize =
                        await printerStorage.getPrinterPaperSize();
                    late PaperSize paperSize;
                    if (printerPaperSize.isNotEmpty) {
                      //check & set printer paper size
                      switch (printerPaperSize) {
                        case '80mm':
                          paperSize = PaperSize.mm80;
                          break;
                        default:
                          paperSize = PaperSize.mm58;
                      }
                    }
                    controller.paperSize = paperSize;
                    readProvider.controller = controller;
                  },
                  builder: (context) => child),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          GlobalService.openDialog(
                            contentWidget: const PrintingProgressWidget(),
                            context: context,
                          );
                        },
                        child: Text(context.tr('screens.printer.btn')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
