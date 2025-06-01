import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_builder_state.dart';
import '../widgets/route_builder_map.dart';
import '../services/route_builder_service.dart';

/// Main screen for the route builder feature
class RouteBuilderScreen extends StatelessWidget {
  const RouteBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Map view (expands to fill available space)
        const Expanded(
          child: RouteBuilderMap(),
        ),
        
        // Sidebar (fixed width of 300px)
        SizedBox(
          width: 300,
          child: Column(
            children: [
              // Sidebar content
              Expanded(
                child: _buildSidebarContent(context),
              ),
              
              // Button panel at bottom
              _buildButtonPanel(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Consumer<RouteBuilderStateProvider>(
      builder: (context, stateProvider, child) {
        switch (stateProvider.currentState) {
          case RouteBuilderState.awaitingStartPoint:
            return const Center(
              child: Text('Click on the map to select a starting point'),
            );
          case RouteBuilderState.choosingNextSegment:
            return const Center(
              child: Text('Select the next segment of your route'),
            );
        }
      },
    );
  }

  Widget _buildButtonPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<RouteBuilderService>().cancel();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RouteBuilderService>().save();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 