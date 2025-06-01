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
    return Column(
      children: [
        // Main content area
        Expanded(
          child: Row(
            children: [
              // Map view (expands to fill available space)
              const Expanded(
                child: RouteBuilderMap(),
              ),
              
              // Sidebar (fixed width of 300px)
              SizedBox(
                width: 300,
                child: _buildSidebarContent(context),
              ),
            ],
          ),
        ),
        
        // Status bar at the bottom
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _buildStatusBar(context),
        ),
      ],
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Consumer2<RouteBuilderStateProvider, RouteBuilderService>(
      builder: (context, stateProvider, routeBuilder, child) {
        // Only show content if we have a selected point
        if (routeBuilder.selectedPoint == null) {
          return const SizedBox.shrink();
        }

        return _buildSegmentList(context, routeBuilder);
      },
    );
  }

  Widget _buildSegmentList(BuildContext context, RouteBuilderService routeBuilder) {
    final segments = routeBuilder.nearbySegments;
    
    if (segments.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('No segments found nearby'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    routeBuilder.undo();
                  },
                  child: const Text('Undo'),
                ),
                ElevatedButton(
                  onPressed: () {
                    routeBuilder.save();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${segments.length} nearby segments:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: segments.length,
            itemBuilder: (context, index) {
              final segment = segments[index];
              return ListTile(
                title: Text(segment.name),
                subtitle: Text('${segment.pointCount} points'),
                trailing: Text(segment.direction),
                onTap: () {
                  // TODO: Handle segment selection
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  routeBuilder.undo();
                },
                child: const Text('Undo'),
              ),
              ElevatedButton(
                onPressed: () {
                  routeBuilder.save();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Consumer<RouteBuilderStateProvider>(
      builder: (context, stateProvider, child) {
        String statusMessage;
        
        switch (stateProvider.currentState) {
          case RouteBuilderState.awaitingStartPoint:
            statusMessage = 'Click on the map to select a starting point';
            break;
          case RouteBuilderState.choosingNextSegment:
            statusMessage = 'Select a segment to continue building the route';
            break;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 